// Вырезает предметы (шапки, очки, банты…) с листа на светлом фоне в отдельные
// PNG с прозрачным фоном. Предметы находятся по отличию от цвета фона листа.
// Запуск: swiftc -O tool/cut_items.swift -o /tmp/cut_items
//         /tmp/cut_items картинка x y ширина высота папка префикс [порог] [мин_площадь] [склейка_px]
// «склейка» — на сколько пикселей соседние части считаются одним предметом (7 по умолчанию; 2 для очков и корон, стоящих близко).
// Предметы нумеруются по строкам, слева направо. Узкие подписи вроде «Hats»
// отсеиваются по высоте (меньше 28 пикселей).
import AppKit
import ImageIO

let a = CommandLine.arguments
let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: a[1]) as CFURL, nil)!
let full = CGImageSourceCreateImageAtIndex(src, 0, nil)!
let region = CGRect(x: Int(a[2])!, y: Int(a[3])!, width: Int(a[4])!, height: Int(a[5])!)
let outDir = a[6], prefix = a[7]
let T = a.count > 8 ? Int(a[8])! : 16
let minArea = a.count > 9 ? Int(a[9])! : 600
let img = full.cropping(to: region)!
let w = img.width, h = img.height
let srgb = CGColorSpace(name: CGColorSpace.sRGB)!
let ctx = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w*4, space: srgb, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
ctx.draw(img, in: CGRect(x: 0, y: 0, width: w, height: h))
let p = ctx.data!.bindMemory(to: UInt8.self, capacity: w*h*4)

// Цвет фона: медиана по каждому каналу.
func median(_ c: Int) -> Int { var hist = [Int](repeating: 0, count: 256); for i in 0..<(w*h) { hist[Int(p[i*4+c])] += 1 }
  var s = 0; for v in 0..<256 { s += hist[v]; if s >= w*h/2 { return v } }; return 255 }
let bg = [median(0), median(1), median(2)]
func diff(_ i: Int) -> Int { max(abs(Int(p[i*4]) - bg[0]), abs(Int(p[i*4+1]) - bg[1]), abs(Int(p[i*4+2]) - bg[2])) }
var fg = [Bool](repeating: false, count: w*h)
for i in 0..<(w*h) { fg[i] = diff(i) > T }

// Склеиваем близкие пиксели (дилатация 7 px) и ищем компоненты.
var dil = fg
let R = a.count > 10 ? Int(a[10])! : 7
for y in 0..<h { for x in 0..<w where fg[y*w+x] {
  for dy in -R...R { let yy = y+dy; if yy < 0 || yy >= h { continue }
    for dx in stride(from: -R, through: R, by: 1) { let xx = x+dx; if xx >= 0 && xx < w { dil[yy*w+xx] = true } } } } }
var seen = [Bool](repeating: false, count: w*h)
struct Comp { var x0: Int, y0: Int, x1: Int, y1: Int, area: Int }
var comps: [Comp] = []
for s in 0..<(w*h) where dil[s] && !seen[s] {
  var c = Comp(x0: w, y0: h, x1: 0, y1: 0, area: 0)
  var todo = [s]; seen[s] = true
  while let i = todo.popLast() {
    let x = i % w, y = i / w
    if fg[i] { c.x0 = min(c.x0,x); c.x1 = max(c.x1,x); c.y0 = min(c.y0,y); c.y1 = max(c.y1,y); c.area += 1 }
    for j in [x > 0 ? i-1 : -1, x < w-1 ? i+1 : -1, y > 0 ? i-w : -1, y < h-1 ? i+w : -1] where j >= 0 && dil[j] && !seen[j] { seen[j] = true; todo.append(j) }
  }
  if c.area >= minArea && (c.y1 - c.y0) >= 28 { comps.append(c) }
}
comps.sort { l, r in
  let lm = (l.y0 + l.y1)/2, rm = (r.y0 + r.y1)/2
  if abs(lm - rm) > 45 { return lm < rm }
  return l.x0 < r.x0
}
for (n, c) in comps.enumerated() {
  let pad = 8
  let x0 = max(0, c.x0 - pad), y0 = max(0, c.y0 - pad), x1 = min(w-1, c.x1 + pad), y1 = min(h-1, c.y1 + pad)
  let cw = x1 - x0 + 1, chh = y1 - y0 + 1
  // Фон = пиксели, близкие к фону и связанные с краем рамки, либо большие
  // замкнутые «окна» (внутри оправы очков).
  var isBg = [Bool](repeating: false, count: cw*chh)
  func near(_ x: Int, _ y: Int) -> Bool { diff((y0+y)*w + x0 + x) <= T - 4 }
  var stack: [Int] = []
  for x in 0..<cw { stack.append(x); stack.append((chh-1)*cw + x) }
  for y in 0..<chh { stack.append(y*cw); stack.append(y*cw + cw-1) }
  while let i = stack.popLast() {
    if isBg[i] { continue }
    let x = i % cw, y = i / cw
    if !near(x, y) { continue }
    isBg[i] = true
    if x > 0 { stack.append(i-1) }; if x < cw-1 { stack.append(i+1) }
    if y > 0 { stack.append(i-cw) }; if y < chh-1 { stack.append(i+cw) }
  }
  // Большие замкнутые участки фона.
  var holeSeen = [Bool](repeating: false, count: cw*chh)
  for s in 0..<(cw*chh) where !isBg[s] && !holeSeen[s] && near(s % cw, s / cw) {
    var comp: [Int] = [], todo = [s]; holeSeen[s] = true
    while let i = todo.popLast() {
      comp.append(i)
      let x = i % cw, y = i / cw
      for j in [x > 0 ? i-1 : -1, x < cw-1 ? i+1 : -1, y > 0 ? i-cw : -1, y < chh-1 ? i+cw : -1] where j >= 0 && !isBg[j] && !holeSeen[j] && near(j % cw, j / cw) { holeSeen[j] = true; todo.append(j) }
    }
    if comp.count > 500 { for i in comp { isBg[i] = true } }
  }
  let o = CGContext(data: nil, width: cw, height: chh, bitsPerComponent: 8, bytesPerRow: cw*4, space: srgb, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
  let q = o.data!.bindMemory(to: UInt8.self, capacity: cw*chh*4)
  for y in 0..<chh { for x in 0..<cw {
    let i = y*cw + x, src = (y0+y)*w + x0 + x
    if isBg[i] { continue }
    var alpha: Float = 1
    // Край: смесь предмета с фоном — делаем полупрозрачным.
    var edge = false
    for (dx, dy) in [(-1,0),(1,0),(0,-1),(0,1),(-1,-1),(1,1),(-1,1),(1,-1)] {
      let nx = x+dx, ny = y+dy
      if nx >= 0 && nx < cw && ny >= 0 && ny < chh && isBg[ny*cw+nx] { edge = true }
    }
    if edge { alpha = min(1, Float(diff(src)) / 60) }
    let al = max(alpha, 0.04)
    for c in 0..<3 {
      let v = (Float(p[src*4+c]) - Float(bg[c]) * (1 - alpha)) / al
      q[i*4+c] = UInt8(max(0, min(255, v)) * alpha)
    }
    q[i*4+3] = UInt8(alpha * 255)
  } }
  let name = String(format: "%@_%02d", prefix, n + 1)
  try! NSBitmapImageRep(cgImage: o.makeImage()!).representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "\(outDir)/\(name).png"))
  print(name, c.x0 + Int(region.minX), c.y0 + Int(region.minY), cw, chh)
}
