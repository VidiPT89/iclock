import SwiftUI

// MARK: - Relógio Dot Matrix (LED 5×7)

struct DotMatrixClockView: View {
    let hours: String
    let minutes: String
    let seconds: String
    let colonVisible: Bool
    let onColor: Color
    let screenWidth: CGFloat

    private let cols       = 5
    private let rows       = 7
    private let dotSpacing: CGFloat = 2.5
    private let colonCols  = 1

    var dotSize: CGFloat {
        // 6 dígitos × 5 cols + 2 colons × 1 col + espaços
        let totalCols = CGFloat(6 * cols + 2 * colonCols)
        let gapCount  = totalCols - 1 + 8   // espaços extra entre grupos
        let available = screenWidth - 32
        return (available - gapCount * dotSpacing) / totalCols
    }

    var body: some View {
        HStack(spacing: groupGap) {
            dotDigit(hours,   at: 0)
            dotDigit(hours,   at: 1)
            dotColon
            dotDigit(minutes, at: 0)
            dotDigit(minutes, at: 1)
            dotColon.opacity(colonVisible ? 1.0 : 0.15)
            dotDigit(seconds, at: 0, dimmed: true)
            dotDigit(seconds, at: 1, dimmed: true)
        }
        .padding(.horizontal, 16)
        .animation(.easeInOut(duration: 0.12), value: colonVisible)
    }

    private var groupGap: CGFloat { dotSpacing * 2 }

    @ViewBuilder
    private func dotDigit(_ str: String, at index: Int, dimmed: Bool = false) -> some View {
        let chars = Array(str)
        let ch: Character = chars.indices.contains(index) ? chars[index] : "0"
        DotMatrixDigit(char: ch, onColor: dimmed ? onColor.opacity(0.55) : onColor,
                       dotSize: dotSize, spacing: dotSpacing)
    }

    private var dotColon: some View {
        DotMatrixColon(onColor: onColor, dotSize: dotSize, spacing: dotSpacing,
                       rows: rows)
    }
}

// MARK: - Dígito individual 5×7

struct DotMatrixDigit: View {
    let char: Character
    let onColor: Color
    let dotSize: CGFloat
    let spacing: CGFloat

    private var bitmap: [[Bool]] { Self.patterns[char] ?? Self.patterns["0"]! }
    private var cols: Int { 5 }
    private var rows: Int { 7 }
    private var step: CGFloat { dotSize + spacing }

    var body: some View {
        Canvas { ctx, _ in
            for row in 0..<rows {
                for col in 0..<cols {
                    let active = bitmap[row][col]
                    let x = CGFloat(col) * step
                    let y = CGFloat(row) * step
                    let rect = CGRect(x: x, y: y, width: dotSize, height: dotSize)
                    let dot  = Path(ellipseIn: rect)
                    let color = active ? onColor : onColor.opacity(0.07)

                    if active {
                        // Glow nos pontos ativos
                        ctx.drawLayer { l in
                            l.addFilter(.blur(radius: dotSize * 0.5))
                            l.opacity = 0.5
                            l.fill(dot, with: .color(onColor))
                        }
                    }
                    ctx.fill(dot, with: .color(color))
                }
            }
        }
        .frame(width: CGFloat(cols) * step - spacing,
               height: CGFloat(rows) * step - spacing)
    }

    // MARK: - Bitmaps 5×7

    static let patterns: [Character: [[Bool]]] = {
        func B(_ s: String) -> [[Bool]] {
            s.split(separator: " ").map { row in row.map { $0 == "1" } }
        }
        return [
            "0": B("01110 10001 10001 10001 10001 10001 01110"),
            "1": B("00100 01100 00100 00100 00100 00100 01110"),
            "2": B("01110 10001 00001 00110 01000 10000 11111"),
            "3": B("01110 10001 00001 00110 00001 10001 01110"),
            "4": B("00010 00110 01010 10010 11111 00010 00010"),
            "5": B("11111 10000 11110 00001 00001 10001 01110"),
            "6": B("00110 01000 10000 11110 10001 10001 01110"),
            "7": B("11111 00001 00010 00100 01000 01000 01000"),
            "8": B("01110 10001 10001 01110 10001 10001 01110"),
            "9": B("01110 10001 10001 01111 00001 00010 01100"),
        ]
    }()
}

// MARK: - Dois-pontos (colon) 1×7

struct DotMatrixColon: View {
    let onColor: Color
    let dotSize: CGFloat
    let spacing: CGFloat
    let rows: Int

    private var step: CGFloat { dotSize + spacing }

    var body: some View {
        Canvas { ctx, sz in
            let dot1y = CGFloat(rows / 2 - 1) * step
            let dot2y = CGFloat(rows / 2 + 1) * step
            let color = onColor

            func drawDot(_ y: CGFloat) {
                let rect = CGRect(x: 0, y: y, width: dotSize, height: dotSize)
                let path = Path(ellipseIn: rect)
                ctx.drawLayer { l in
                    l.addFilter(.blur(radius: dotSize * 0.5))
                    l.opacity = 0.45
                    l.fill(path, with: .color(color))
                }
                ctx.fill(path, with: .color(color))
            }

            drawDot(dot1y)
            drawDot(dot2y)
        }
        .frame(width: dotSize, height: CGFloat(rows) * step - spacing)
    }
}
