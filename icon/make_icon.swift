// The icon, drawn: one waveform splitting into four coloured lanes (vocals, bass, drums, others); the version under it.
import AppKit
let S: CGFloat = 1024
let version = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "1"
let img = NSImage(size: NSSize(width: S, height: S)); img.lockFocus()
let ctx = NSGraphicsContext.current!.cgContext
ctx.addPath(CGPath(roundedRect: CGRect(x: 100, y: 100, width: 824, height: 824), cornerWidth: 180, cornerHeight: 180, transform: nil))
ctx.setFillColor(NSColor(calibratedRed: 0.04, green: 0.05, blue: 0.10, alpha: 1).cgColor); ctx.fillPath()
let cols = [NSColor(calibratedRed: 0.42, green: 0.80, blue: 0.45, alpha: 1), NSColor(calibratedRed: 1.0, green: 0.42, blue: 0.37, alpha: 1),
            NSColor(calibratedRed: 1.0, green: 0.84, blue: 0.29, alpha: 1), NSColor(calibratedRed: 0.35, green: 0.64, blue: 0.94, alpha: 1)]
// the whole song on the left
ctx.setFillColor(NSColor(calibratedWhite: 0.85, alpha: 1).cgColor)
for i in 0..<9 { let h = CGFloat([80, 200, 140, 260, 120, 230, 170, 90, 150][i]); ctx.fill(CGRect(x: 190 + CGFloat(i) * 26, y: 520 - h / 2, width: 14, height: h)) }
// four lanes on the right
for (k, c) in cols.enumerated() {
    let y = 730 - CGFloat(k) * 130
    ctx.setStrokeColor(c.cgColor); ctx.setLineWidth(10)
    ctx.move(to: CGPoint(x: 430, y: 520)); ctx.addCurve(to: CGPoint(x: 560, y: y), control1: CGPoint(x: 500, y: 520), control2: CGPoint(x: 490, y: y)); ctx.strokePath()
    ctx.setFillColor(c.cgColor)
    for i in 0..<7 { let h = CGFloat([40, 90, 60, 100, 50, 80, 30][(i + k * 2) % 7]); ctx.fill(CGRect(x: 580 + CGFloat(i) * 34, y: y - h / 2, width: 18, height: h)) }
}
("v" + version as NSString).draw(at: NSPoint(x: 170, y: 150), withAttributes: [.font: NSFont.systemFont(ofSize: 92, weight: .semibold), .foregroundColor: NSColor(calibratedWhite: 0.78, alpha: 1)])
img.unlockFocus()
try! NSBitmapImageRep(data: img.tiffRepresentation!)!.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "icon_1024.png"))
