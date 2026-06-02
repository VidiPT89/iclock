import SwiftUI

// Segments: [A-top, B-topRight, C-botRight, D-bottom, E-botLeft, F-topLeft, G-middle]
private let digitMap: [Character: [Bool]] = [
    "0": [true,  true,  true,  true,  true,  true,  false],
    "1": [false, true,  true,  false, false, false, false],
    "2": [true,  true,  false, true,  true,  false, true ],
    "3": [true,  true,  true,  true,  false, false, true ],
    "4": [false, true,  true,  false, false, true,  true ],
    "5": [true,  false, true,  true,  false, true,  true ],
    "6": [true,  false, true,  true,  true,  true,  true ],
    "7": [true,  true,  true,  false, false, false, false],
    "8": [true,  true,  true,  true,  true,  true,  true ],
    "9": [true,  true,  true,  true,  false, true,  true ],
]

// MARK: - Digit

struct SevenSegmentDigit: View {
    let char: Character
    let onColor: Color
    let offColor: Color
    let width: CGFloat
    var glow: Bool = true

    var height: CGFloat { width * 1.9 }

    private var segs: [Bool] { digitMap[char] ?? Array(repeating: false, count: 7) }

    var body: some View {
        Canvas { ctx, sz in
            let w = sz.width, h = sz.height
            let t = w * 0.14
            let g = t * 0.20

            let paths: [Path] = [
                hSeg(g + t,   g,           w - 2*(g+t), t      ),  // A top
                vSeg(w-g-t,   g + t,       t,           h/2-g*2-t), // B top-right
                vSeg(w-g-t,   h/2 + g,     t,           h/2-g*2-t), // C bot-right
                hSeg(g + t,   h - g - t,   w - 2*(g+t), t      ),  // D bottom
                vSeg(g,       h/2 + g,     t,           h/2-g*2-t), // E bot-left
                vSeg(g,       g + t,       t,           h/2-g*2-t), // F top-left
                hSeg(g + t,   h/2 - t/2,  w - 2*(g+t), t      ),  // G middle
            ]

            for (i, path) in paths.enumerated() {
                let active = segs[i]
                let color  = active ? onColor : offColor

                if active && glow {
                    ctx.drawLayer { gl in
                        gl.addFilter(.blur(radius: 7))
                        gl.opacity = 0.65
                        gl.fill(path, with: .color(onColor))
                    }
                }
                ctx.fill(path, with: .color(color))
            }
        }
        .frame(width: width, height: height)
    }

    private func hSeg(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> Path {
        Path(roundedRect: CGRect(x: x, y: y, width: max(w, 0), height: h), cornerRadius: h * 0.45)
    }

    private func vSeg(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> Path {
        Path(roundedRect: CGRect(x: x, y: y, width: w, height: max(h, 0)), cornerRadius: w * 0.45)
    }
}

// MARK: - Colon (dois pontos)

struct SevenSegmentColon: View {
    let onColor: Color
    let offColor: Color
    let digitWidth: CGFloat
    let blink: Bool

    private var colonW: CGFloat  { digitWidth * 0.36 }
    private var colonH: CGFloat  { digitWidth * 1.9  }
    private var dotD:   CGFloat  { digitWidth * 0.16 }

    var body: some View {
        Canvas { ctx, sz in
            let cx = sz.width / 2
            let r  = dotD / 2
            let color: GraphicsContext.Shading = .color(blink ? onColor : offColor)

            ctx.fill(circle(cx, sz.height * 0.30, r), with: color)
            ctx.fill(circle(cx, sz.height * 0.70, r), with: color)
        }
        .frame(width: colonW, height: colonH)
        .animation(.easeInOut(duration: 0.12), value: blink)
    }

    private func circle(_ cx: CGFloat, _ cy: CGFloat, _ r: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
    }
}
