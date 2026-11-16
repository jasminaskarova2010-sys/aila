// Убирает белый фон с кадров видео и собирает APNG с прозрачностью.
// Запуск: swiftc -O tool/cutout_video.swift -o /tmp/cutout
//         /tmp/cutout видео.mp4 assets/имя.png 320 2 папка_для_проверочных_кадров
// 320 — размер кадра, 2 — брать каждый второй кадр. Нужен белый фон в видео.
import AVFoundation
import AppKit
import Vision
import ImageIO
import UniformTypeIdentifiers

let a = CommandLine.arguments
let outSize = Int(a[3])!, step = Int(a[4])!
let asset = AVURLAsset(url: URL(fileURLWithPath: a[1]))

func rgba(_ img: CGImage) -> (CGContext, UnsafeMutablePointer<UInt8>) {
  let ctx = CGContext(data: nil, width: img.width, height: img.height, bitsPerComponent: 8, bytesPerRow: img.width*4,
    space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
  ctx.draw(img, in: CGRect(x: 0, y: 0, width: img.width, height: img.height))
  return (ctx, ctx.data!.bindMemory(to: UInt8.self, capacity: img.width*img.height*4))
}

func cutout(_ img: CGImage) throws -> CGImage {
  let handler = VNImageRequestHandler(cgImage: img)
  let req = VNGenerateForegroundInstanceMaskRequest()
  try handler.perform([req])
  let obs = req.results!.first!
  let mask = try obs.generateScaledMaskForImage(forInstances: obs.allInstances, from: handler)
  CVPixelBufferLockBaseAddress(mask, .readOnly)
  defer { CVPixelBufferUnlockBaseAddress(mask, .readOnly) }
  let mw = CVPixelBufferGetWidth(mask), mh = CVPixelBufferGetHeight(mask), mbpr = CVPixelBufferGetBytesPerRow(mask)
  let mbase = CVPixelBufferGetBaseAddress(mask)!
  let (ctx, p) = rgba(img)
  let w = img.width, h = img.height
  precondition(mw == w && mh == h)
  for y in 0..<h {
    let mrow = mbase.advanced(by: y*mbpr).assumingMemoryBound(to: Float32.self)
    for x in 0..<w {
      let i = (y*w + x)*4
      let m = max(0, min(1, mrow[x]))
      let r = Float(p[i]), g = Float(p[i+1]), b = Float(p[i+2])
      // Тень под звёздочкой светло-серая, с тёплым оттенком от самой звёздочки.
      // Иногда маска захватывает её середину, поэтому внизу кадра всё светлое и
      // почти серое считается тенью.
      let spread = max(r, g, b) - min(r, g, b)
      let low = y > h * 78 / 100
      let isShadow = min(r, g, b) > 120 && (low ? spread < 40 : (spread < 14 && m < 0.95))
      if m > 0.02 && !isShadow {
        // Кадр = цвет*альфа + белый*(1-альфа): вычитаем белую подложку.
        let k = (1 - m) * 255
        p[i] = UInt8(max(0, min(255*m, r - k))); p[i+1] = UInt8(max(0, min(255*m, g - k))); p[i+2] = UInt8(max(0, min(255*m, b - k)))
        p[i+3] = UInt8(m * 255)
      } else {
        // Вне звёздочки остаётся только мягкая серая тень.
        let mn = min(r, g, b), mx = max(r, g, b)
        let s = 255 - mn
        let alpha: Float = (mx - mn < (low ? 40 : 14) && s > 10) ? s : 0
        p[i] = 0; p[i+1] = 0; p[i+2] = 0; p[i+3] = UInt8(alpha)
      }
    }
  }
  return ctx.makeImage()!
}

func bbox(_ img: CGImage) -> CGRect {
  let (ctx, p) = rgba(img)
  var x0 = img.width, y0 = img.height, x1 = 0, y1 = 0
  withExtendedLifetime(ctx) {
    for y in 0..<img.height { for x in 0..<img.width where p[(y*img.width+x)*4+3] > 12 {
      x0 = min(x0, x); x1 = max(x1, x); y0 = min(y0, y); y1 = max(y1, y) } }
  }
  return CGRect(x: x0, y: y0, width: x1-x0+1, height: y1-y0+1)
}

let sem = DispatchSemaphore(value: 0)
Task {
  let d = CMTimeGetSeconds(try await asset.load(.duration))
  let fps = Double(try await asset.loadTracks(withMediaType: .video)[0].load(.nominalFrameRate))
  let gen = AVAssetImageGenerator(asset: asset)
  gen.appliesPreferredTrackTransform = true
  gen.requestedTimeToleranceBefore = .zero; gen.requestedTimeToleranceAfter = .zero
  let total = Int((d * fps).rounded())
  var frames: [CGImage] = []
  var box = CGRect.null
  var n = 0
  while n < total {
    let (img, _) = try await gen.image(at: CMTime(seconds: Double(n)/fps, preferredTimescale: 600))
    let cut = try cutout(img)
    frames.append(cut); box = box.union(bbox(cut))
    n += step
  }
  // Общий квадрат для всех кадров, чтобы звёздочка не прыгала.
  let side = max(box.width, box.height) + 16
  let sq = CGRect(x: box.midX - side/2, y: box.midY - side/2, width: side, height: side)
  print("frames", frames.count, "bbox", box, "square", sq)
  let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: a[2]) as CFURL, UTType.png.identifier as CFString, frames.count, nil)!
  CGImageDestinationSetProperties(dest, [kCGImagePropertyPNGDictionary: [kCGImagePropertyAPNGLoopCount: 0]] as CFDictionary)
  let delay = Double(step)/fps
  for (i, f) in frames.enumerated() {
    let ctx = CGContext(data: nil, width: outSize, height: outSize, bitsPerComponent: 8, bytesPerRow: outSize*4,
      space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.interpolationQuality = .high
    let scale = CGFloat(outSize)/side
    // CGContext рисует снизу вверх: переводим квадрат в его координаты.
    let oy = CGFloat(f.height) - sq.maxY
    ctx.draw(f, in: CGRect(x: -sq.minX*scale, y: -oy*scale, width: CGFloat(f.width)*scale, height: CGFloat(f.height)*scale))
    let small = ctx.makeImage()!
    CGImageDestinationAddImage(dest, small, [kCGImagePropertyPNGDictionary: [kCGImagePropertyAPNGDelayTime: delay]] as CFDictionary)
    if i % max(1, frames.count/8) == 0 {
      let rep = NSBitmapImageRep(cgImage: small)
      try rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "\(a[5])/f\(i).png"))
    }
  }
  print("ok", CGImageDestinationFinalize(dest))
  sem.signal()
}
sem.wait()
