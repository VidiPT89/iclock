#!/usr/bin/swift
import AppKit
import CoreGraphics

let S: CGFloat = 1024
let outPath = (NSString(string:
    "~/Desktop/iClock/iClock/iClock/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png")
    as NSString).expandingTildeInPath as String

let cs  = CGColorSpaceCreateDeviceRGB()
let ctx = CGContext(data: nil, width: Int(S), height: Int(S),
                   bitsPerComponent: 8, bytesPerRow: 0, space: cs,
                   bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
ctx.translateBy(x: 0, y: S); ctx.scaleBy(x: 1, y: -1)

// ─── Cores ────────────────────────────────────────────────────────────────────
let amberOn  = CGColor(red: 1.00, green: 0.62, blue: 0.07, alpha: 1.00)
let amberDim = CGColor(red: 1.00, green: 0.55, blue: 0.05, alpha: 0.055)
let glowCol  = CGColor(red: 1.00, green: 0.52, blue: 0.04, alpha: 1.00)

// ─── Utilitários ─────────────────────────────────────────────────────────────
func fillRR(_ r: CGRect, rx: CGFloat, _ c: CGColor) {
    let p = CGMutablePath()
    p.addRoundedRect(in: r, cornerWidth: rx, cornerHeight: rx)
    ctx.setFillColor(c); ctx.addPath(p); ctx.fillPath()
}
func strokeRR(_ r: CGRect, rx: CGFloat, _ c: CGColor, lw: CGFloat) {
    let p = CGMutablePath()
    p.addRoundedRect(in: r, cornerWidth: rx, cornerHeight: rx)
    ctx.setStrokeColor(c); ctx.setLineWidth(lw); ctx.addPath(p); ctx.strokePath()
}
func drawText(_ s: String, font: NSFont, color: NSColor, at pt: CGPoint,
              kern: CGFloat = 0) {
    var attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
    if kern != 0 { attrs[.kern] = kern }
    let a = NSAttributedString(string: s, attributes: attrs)
    let sz = a.size()
    ctx.saveGState()
    ctx.translateBy(x: pt.x - sz.width/2, y: pt.y - sz.height/2)
    ctx.scaleBy(x: 1, y: -1); ctx.translateBy(x: 0, y: -sz.height)
    a.draw(at: .zero)
    ctx.restoreGState()
}

// ─── Segmento com glow neon (multi-pass) ─────────────────────────────────────
func neonPath(_ path: CGMutablePath, on: Bool) {
    if on {
        // 3 camadas de glow → efeito tubo de néon
        for (blur, alpha) in [(38.0,0.30),(18.0,0.55),(7.0,0.80)] {
            ctx.saveGState()
            ctx.setShadow(offset:.zero, blur:CGFloat(blur),
                          color:CGColor(red:1,green:0.52,blue:0.04,alpha:alpha))
            ctx.setFillColor(amberOn); ctx.addPath(path); ctx.fillPath()
            ctx.restoreGState()
        }
        ctx.setFillColor(CGColor(red:1,green:0.78,blue:0.45,alpha:1)) // núcleo brilhante
        ctx.addPath(path); ctx.fillPath()
    } else {
        ctx.setFillColor(amberDim); ctx.addPath(path); ctx.fillPath()
    }
}

// Segmentos: [A,B,C,D,E,F,G]
let segTable: [[Bool]] = [
    [true,true,true,true,true,true,false],
    [false,true,true,false,false,false,false],
    [true,true,false,true,true,false,true],
    [true,true,true,true,false,false,true],
    [false,true,true,false,false,true,true],
    [true,false,true,true,false,true,true],
    [true,false,true,true,true,true,true],
    [true,true,true,false,false,false,false],
    [true,true,true,true,true,true,true],
    [true,true,true,true,false,true,true],
]

func drawDigit(_ d: Int, x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) {
    let t = w * 0.135, g = t * 0.22
    let s = segTable[d % 10]

    func hSeg(_ bx:CGFloat,_ by:CGFloat,_ bw:CGFloat,_ bh:CGFloat, i:Int) {
        let p = CGMutablePath()
        p.addRoundedRect(in:CGRect(x:bx,y:by,width:max(bw,0),height:bh),
                         cornerWidth:bh*0.45, cornerHeight:bh*0.45)
        neonPath(p, on: s[i])
    }
    func vSeg(_ bx:CGFloat,_ by:CGFloat,_ bw:CGFloat,_ bh:CGFloat, i:Int) {
        let p = CGMutablePath()
        p.addRoundedRect(in:CGRect(x:bx,y:by,width:bw,height:max(bh,0)),
                         cornerWidth:bw*0.45, cornerHeight:bw*0.45)
        neonPath(p, on: s[i])
    }

    hSeg(x+g+t, y+g,         w-2*(g+t), t, i:0)
    vSeg(x+w-g-t, y+g+t,     t, h/2-g*2-t, i:1)
    vSeg(x+w-g-t, y+h/2+g,   t, h/2-g*2-t, i:2)
    hSeg(x+g+t, y+h-g-t,     w-2*(g+t), t, i:3)
    vSeg(x+g, y+h/2+g,       t, h/2-g*2-t, i:4)
    vSeg(x+g, y+g+t,         t, h/2-g*2-t, i:5)
    hSeg(x+g+t, y+h/2-t/2,   w-2*(g+t), t, i:6)
}

func drawColon(cx: CGFloat, cy: CGFloat, r: CGFloat) {
    for dy in [-r*1.6, r*1.6] {
        let p = CGMutablePath()
        p.addEllipse(in: CGRect(x:cx-r, y:cy+dy-r, width:r*2, height:r*2))
        neonPath(p, on: true)
    }
}

// ═════════════════════════════════════════════════════════════════════════════
// COMPOSIÇÃO
// ═════════════════════════════════════════════════════════════════════════════

// ── Máscara arredondada iOS
let mask = CGMutablePath()
mask.addRoundedRect(in:CGRect(x:0,y:0,width:S,height:S),
                    cornerWidth:230, cornerHeight:230)
ctx.addPath(mask); ctx.clip()

// ── 1. Fundo puro escuro
ctx.setFillColor(CGColor(red:0.025,green:0.018,blue:0.010,alpha:1))
ctx.fill(CGRect(x:0,y:0,width:S,height:S))

// ── 2. Grelha de pontos muito subtil (efeito ecrã LED)
ctx.setFillColor(CGColor(red:1,green:0.55,blue:0.05,alpha:0.032))
let gs: CGFloat = 20
var gx: CGFloat = gs/2
while gx < S { var gy: CGFloat = gs/2
    while gy < S {
        ctx.fillEllipse(in:CGRect(x:gx-1.2,y:gy-1.2,width:2.4,height:2.4))
        gy += gs }
    gx += gs }

// ── 3. Rectângulo de exibição (área escura ligeiramente aquecida)
let disp = CGRect(x: 52, y: 52, width: S-104, height: S-104)
fillRR(disp, rx: 72, CGColor(red:0.04,green:0.028,blue:0.015,alpha:1))

// ── 4. Moldura neon (linha exterior brilhante)
ctx.saveGState()
ctx.setShadow(offset:.zero, blur:22,
              color:CGColor(red:1,green:0.52,blue:0.04,alpha:0.70))
strokeRR(disp, rx: 72, CGColor(red:1,green:0.60,blue:0.07,alpha:0.90), lw:3)
ctx.restoreGState()
// Linha interior da moldura (espelho)
strokeRR(disp.insetBy(dx:10,dy:10), rx:64,
         CGColor(red:1,green:0.55,blue:0.05,alpha:0.15), lw:1)

// ── 5. Cantos decorativos em L (estilo retro HUD)
let cs2: CGFloat = 54, cLw: CGFloat = 4
let corners: [(CGFloat,CGFloat,CGFloat,CGFloat)] = [
    (disp.minX+18, disp.minY+18,  1,  1),
    (disp.maxX-18, disp.minY+18, -1,  1),
    (disp.minX+18, disp.maxY-18,  1, -1),
    (disp.maxX-18, disp.maxY-18, -1, -1),
]
ctx.setStrokeColor(CGColor(red:1,green:0.60,blue:0.07,alpha:0.55))
ctx.setLineWidth(cLw); ctx.setLineCap(.square)
for (cx2,cy2,sx2,sy2) in corners {
    ctx.saveGState()
    ctx.setShadow(offset:.zero,blur:10,
                  color:CGColor(red:1,green:0.52,blue:0.04,alpha:0.55))
    ctx.move(to:CGPoint(x:cx2,y:cy2+sy2*cs2))
    ctx.addLine(to:CGPoint(x:cx2,y:cy2))
    ctx.addLine(to:CGPoint(x:cx2+sx2*cs2,y:cy2))
    ctx.strokePath()
    ctx.restoreGState()
}

// ── 6. Linha fina central (separa HH de MM) — decorativa
ctx.setStrokeColor(CGColor(red:1,green:0.55,blue:0.05,alpha:0.06))
ctx.setLineWidth(1)
ctx.move(to:CGPoint(x:S/2,y:disp.minY+36))
ctx.addLine(to:CGPoint(x:S/2,y:disp.maxY-36)); ctx.strokePath()

// ── 7. Dígitos  "12:00"
let dw: CGFloat = 152
let dh: CGFloat = dw * 1.85          // ≈ 281
let colonW: CGFloat = 42
let sp: CGFloat = 11
let totalW = dw*4 + colonW + sp*4    // ≈ 730
let dx0 = (S - totalW) / 2
let dy0 = S/2 - dh/2 - 18           // ligeiramente acima do centro

drawDigit(1, x:dx0,                   y:dy0, w:dw, h:dh)
drawDigit(2, x:dx0+dw+sp,             y:dy0, w:dw, h:dh)
drawColon(cx:dx0+dw*2+sp*2+colonW/2, cy:dy0+dh/2, r:12)
drawDigit(0, x:dx0+dw*2+colonW+sp*3, y:dy0, w:dw, h:dh)
drawDigit(0, x:dx0+dw*3+colonW+sp*4, y:dy0, w:dw, h:dh)

// ── 8. Label "iClock" — pequeno, dim, abaixo dos dígitos
let labelY = dy0 + dh + 44
drawText("iClock",
         font: NSFont.systemFont(ofSize: 46, weight: .thin),
         color: NSColor(red:1,green:0.60,blue:0.07,alpha:0.32),
         at: CGPoint(x:S/2, y:labelY), kern:10)

// Traço fino sob label
ctx.saveGState()
ctx.setShadow(offset:.zero,blur:6,
              color:CGColor(red:1,green:0.52,blue:0.04,alpha:0.30))
ctx.setStrokeColor(CGColor(red:1,green:0.58,blue:0.06,alpha:0.28))
ctx.setLineWidth(1)
ctx.move(to:CGPoint(x:S/2-70, y:labelY+28))
ctx.addLine(to:CGPoint(x:S/2+70, y:labelY+28)); ctx.strokePath()
ctx.restoreGState()

// ── 9. Vinheta escura nos cantos
let vig = CGGradient(colorsSpace: cs,
    colors:[CGColor(red:0,green:0,blue:0,alpha:0),
            CGColor(red:0,green:0,blue:0,alpha:0.55)] as CFArray,
    locations:[0.42,1])!
ctx.drawRadialGradient(vig,
    startCenter:CGPoint(x:S/2,y:S/2), startRadius:S*0.28,
    endCenter:  CGPoint(x:S/2,y:S/2), endRadius:S*0.72,
    options:[.drawsAfterEndLocation])

// ── Guardar ────────────────────────────────────────────────────────────────
let image = ctx.makeImage()!
let rep   = NSBitmapImageRep(cgImage: image)
let data  = rep.representation(using: .png, properties: [:])!
try! data.write(to: URL(fileURLWithPath: outPath))
print("✓ Ícone neon retro guardado: \(outPath)")
