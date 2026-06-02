import SwiftUI

struct AnalogClockView: View {
    let hours: String
    let minutes: String
    let seconds: String
    let onColor: Color
    let size: CGFloat       // diâmetro do relógio

    private var now: Date { Date() }

    var body: some View {
        Canvas { ctx, sz in
            let cx  = sz.width  / 2
            let cy  = sz.height / 2
            let R   = min(cx, cy) - 6      // raio do mostrador
            let ctr = CGPoint(x: cx, y: cy)

            drawBezel(ctx, cx: cx, cy: cy, R: R)
            drawFace(ctx, cx: cx, cy: cy, R: R)
            drawTicks(ctx, ctr: ctr, R: R)
            drawNumbers(ctx, ctr: ctr, R: R)

            let cal   = Calendar.current
            let h     = Double(cal.component(.hour,   from: now)) + Double(cal.component(.minute, from: now)) / 60
            let m     = Double(cal.component(.minute, from: now)) + Double(cal.component(.second, from: now)) / 60
            let s     = Double(cal.component(.second, from: now))

            drawHand(ctx, ctr: ctr, angle: h / 12 * 2 * .pi - .pi / 2,
                     length: R * 0.50, width: 5.5, color: onColor, hasCap: true)
            drawHand(ctx, ctr: ctr, angle: m / 60 * 2 * .pi - .pi / 2,
                     length: R * 0.74, width: 3.5, color: onColor, hasCap: true)
            drawHand(ctx, ctr: ctr, angle: s / 60 * 2 * .pi - .pi / 2,
                     length: R * 0.84, width: 1.5, color: .red, hasCap: false)
            // Contrapeso do ponteiro dos segundos
            drawHand(ctx, ctr: ctr, angle: s / 60 * 2 * .pi - .pi / 2 + .pi,
                     length: R * 0.18, width: 2.5, color: .red, hasCap: false)

            // Tampa central
            drawCenter(ctx, ctr: ctr)
        }
        .frame(width: size, height: size)
    }

    // MARK: - Componentes desenhados

    private func drawBezel(_ ctx: GraphicsContext, cx: CGFloat, cy: CGFloat, R: CGFloat) {
        let bezelR = R + 10
        let rect = CGRect(x: cx - bezelR, y: cy - bezelR, width: bezelR * 2, height: bezelR * 2)

        // Aro exterior gradiente (retro metal)
        ctx.drawLayer { l in
            l.fill(Path(ellipseIn: rect), with: .color(Color(white: 0.22)))
        }
        // Sombra interior do aro
        let innerRect = CGRect(x: cx - R - 2, y: cy - R - 2, width: (R + 2) * 2, height: (R + 2) * 2)
        ctx.fill(Path(ellipseIn: innerRect), with: .color(Color(white: 0.10)))
    }

    private func drawFace(_ ctx: GraphicsContext, cx: CGFloat, cy: CGFloat, R: CGFloat) {
        let faceRect = CGRect(x: cx - R, y: cy - R, width: R * 2, height: R * 2)
        // Fundo do mostrador — escuro quente
        ctx.fill(Path(ellipseIn: faceRect), with: .color(Color(red: 0.08, green: 0.06, blue: 0.04)))
        // Anel interior decorativo
        ctx.stroke(Path(ellipseIn: faceRect.insetBy(dx: 8, dy: 8)),
                   with: .color(onColor.opacity(0.12)), lineWidth: 1)
    }

    private func drawTicks(_ ctx: GraphicsContext, ctr: CGPoint, R: CGFloat) {
        for i in 0..<60 {
            let angle    = Double(i) * .pi / 30 - .pi / 2
            let isHour   = i % 5 == 0
            let isQuarter = i % 15 == 0
            let outerR   = R * 0.95
            let innerR   = isQuarter ? R * 0.76 : isHour ? R * 0.82 : R * 0.90
            let lineW: CGFloat = isQuarter ? 3.5 : isHour ? 2.0 : 0.8

            let outer = CGPoint(x: ctr.x + cos(angle) * outerR,
                                y: ctr.y + sin(angle) * outerR)
            let inner = CGPoint(x: ctr.x + cos(angle) * innerR,
                                y: ctr.y + sin(angle) * innerR)

            var path = Path()
            path.move(to: inner)
            path.addLine(to: outer)

            let opacity: Double = isHour ? 1.0 : 0.35
            ctx.stroke(path, with: .color(onColor.opacity(opacity)), lineWidth: lineW)
        }
    }

    private func drawNumbers(_ ctx: GraphicsContext, ctr: CGPoint, R: CGFloat) {
        let numR = R * 0.68
        let hours = [12, 3, 6, 9]
        for (i, h) in hours.enumerated() {
            let angle = Double(i) * .pi / 2 - .pi / 2
            let pos = CGPoint(x: ctr.x + cos(angle) * numR,
                              y: ctr.y + sin(angle) * numR)
            let text = Text(String(h))
                .font(.system(size: R * 0.14, weight: .bold, design: .rounded))
                .foregroundColor(onColor)
            ctx.draw(text, at: pos, anchor: .center)
        }
    }

    private func drawHand(_ ctx: GraphicsContext,
                          ctr: CGPoint, angle: Double, length: CGFloat,
                          width: CGFloat, color: Color, hasCap: Bool) {
        let tip = CGPoint(x: ctr.x + cos(angle) * length,
                          y: ctr.y + sin(angle) * length)
        // Sombra da mão
        ctx.drawLayer { l in
            l.addFilter(.blur(radius: 2))
            l.opacity = 0.4
            var shadow = Path()
            shadow.move(to: ctr)
            shadow.addLine(to: CGPoint(x: tip.x + 2, y: tip.y + 2))
            l.stroke(shadow, with: .color(.black), style: StrokeStyle(lineWidth: width + 1, lineCap: .round))
        }
        // Mão
        var path = Path()
        path.move(to: ctr)
        path.addLine(to: tip)
        ctx.stroke(path, with: .color(color),
                   style: StrokeStyle(lineWidth: width, lineCap: .round))

        if hasCap {
            // Ponta arredondada
            let capR = width * 0.7
            ctx.fill(Path(ellipseIn: CGRect(x: tip.x - capR, y: tip.y - capR,
                                            width: capR * 2, height: capR * 2)),
                     with: .color(color))
        }
    }

    private func drawCenter(_ ctx: GraphicsContext, ctr: CGPoint) {
        // Disco central retro
        let r: CGFloat = 7
        ctx.fill(Path(ellipseIn: CGRect(x: ctr.x - r, y: ctr.y - r,
                                        width: r * 2, height: r * 2)),
                 with: .color(Color(white: 0.20)))
        let rInner: CGFloat = 3.5
        ctx.fill(Path(ellipseIn: CGRect(x: ctr.x - rInner, y: ctr.y - rInner,
                                        width: rInner * 2, height: rInner * 2)),
                 with: .color(.red))
    }
}
