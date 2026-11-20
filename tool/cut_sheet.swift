// Режет лист стикеров на белом фоне на отдельные PNG с прозрачным фоном.
// Запуск: swiftc -O tool/cut_sheet.swift -o /tmp/cut_sheet
//         /tmp/cut_sheet лист.webp папка 3 4 360 имя1 имя2 ... (по строкам, слева направо)
// Белый фон убирается заливкой от краёв ячейки: белое внутри (блики в глазах)
// остаётся. Каждый стикер обрезается по границе и ставится в квадрат.
import AppKit
import ImageIO

let a = CommandLine.arguments
let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: a[1]) as CFURL, nil)!
let sheet = CGImageSourceCreateImageAtIndex(src, 0, nil)!
let outDir = a[2], cols = Int(a[3])!, rows = Int(a[4])!, outSize = Int(a[5])!
let names = Array(a[6...])
let cw = sheet.width / cols, ch = sheet.height / rows
let srgb = CGColorSpace(name: CGColorSpace.sRGB)!

func white(_ p: UnsafeMutablePointer<UInt8>, _ i: Int) -> Bool { p[i*4] > 238 && p[i*4+1] > 238 && p[i*4+2] > 238 }

for (n, name) in names.enumerated() {
  let r = n / cols, c = n % cols
  let rect = CGRect(x: c*cw, y: r*ch, width: cw, height: ch)
  guard let cell = sheet.cropping(to: rect) else { continue }
  let w = cell.width, h = cell.height
  let ctx = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w*4, space: srgb, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
  ctx.draw(cell, in: CGRect(x: 0, y: 0, width: w, height: h))
  let p = ctx.data!.bindMemory(to: UInt8.self, capacity: w*h*4)
  var bg = [Bool](repeating: false, count: w*h)
  var stack: [Int] = []
  for x in 0..<w { stack.append(x); stack.append((h-1)*w + x) }
  for y in 0..<h { stack.append(y*w); stack.append(y*w + w-1) }
  while let i = stack.popLast() {
    if bg[i] || !white(p, i) { continue }
    bg[i] = true
    let x = i % w, y = i / w
    if x > 0 { stack.append(i-1) }; if x < w-1 { stack.append(i+1) }
    if y > 0 { stack.append(i-w) }; if y < h-1 { stack.append(i+w) }
  }
  // Обломки соседних стикеров у края ячейки: маленькие куски, касающиеся края.
  var seen = [Bool](repeating: false, count: w*h)
  for start in 0..<(w*h) where !bg[start] && !seen[start] {
    var comp: [Int] = [], todo = [start], touches = false
    seen[start] = true
    while let i = todo.popLast() {
      comp.append(i)
      let x = i % w, y = i / w
      if x == 0 || y == 0 || x == w-1 || y == h-1 { touches = true }
      for j in [x > 0 ? i-1 : -1, x < w-1 ? i+1 : -1, y > 0 ? i-w : -1, y < h-1 ? i+w : -1] where j >= 0 && !bg[j] && !seen[j] {
        seen[j] = true; todo.append(j)
      }
    }
    if touches && comp.count < 2500 { for i in comp { bg[i] = true } }
  }
  for i in 0..<(w*h) where bg[i] { p[i*4] = 0; p[i*4+1] = 0; p[i*4+2] = 0; p[i*4+3] = 0 }
  // Кайма: пиксели у фона, смешанные с белым, делаем полупрозрачными.
  for y in 1..<(h-1) { for x in 1..<(w-1) {
    let i = y*w + x
    if bg[i] { continue }
    if bg[i-1] || bg[i+1] || bg[i-w] || bg[i+w] {
      let mn = Float(min(p[i*4], p[i*4+1], p[i*4+2]))
      if mn > 140 {
        let al = max(0, min(1, (238 - mn) / 98))
        let k = (1 - al) * 255
        for q in 0..<3 { p[i*4+q] = UInt8(max(0, min(255*al, Float(p[i*4+q]) - k))) }
        p[i*4+3] = UInt8(al * 255)
      }
    }
  } }
  var x0 = w, y0 = h, x1 = 0, y1 = 0
  for y in 0..<h { for x in 0..<w where p[(y*w+x)*4+3] > 12 { x0 = min(x0,x); x1 = max(x1,x); y0 = min(y0,y); y1 = max(y1,y) } }
  let side = max(x1-x0, y1-y0) + 24
  let full = ctx.makeImage()!
  let o = CGContext(data: nil, width: outSize, height: outSize, bitsPerComponent: 8, bytesPerRow: outSize*4, space: srgb, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
  o.interpolationQuality = .high
  let s = CGFloat(outSize) / CGFloat(side)
  let cx = (x0+x1)/2, cy = (y0+y1)/2
  let sx = CGFloat(cx - side/2), sy = CGFloat(h - (cy + side/2))
  o.draw(full, in: CGRect(x: -sx*s, y: -sy*s, width: CGFloat(w)*s, height: CGFloat(h)*s))
  try! NSBitmapImageRep(cgImage: o.makeImage()!).representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "\(outDir)/\(name).png"))
}
