import SwiftUI

// MARK: - Relógio Flip completo

struct FlipClockView: View {
    let hours: String
    let minutes: String
    let seconds: String
    let onColor: Color
    let screenWidth: CGFloat

    private let spacing: CGFloat  = 6
    private let colonW: CGFloat   = 14
    private let secScale: CGFloat = 0.82

    var digitW: CGFloat {
        // 4 dígitos + 2 dígitos (sec) + 2 colons
        let units = 4.0 + 2.0 * secScale + 2.0 * (colonW / 56)
        let totalSpacing = 6.0 * spacing
        return (screenWidth - totalSpacing) / units
    }

    var body: some View {
        HStack(spacing: spacing) {
            flipDigit(hours,   at: 0, w: digitW)
            flipDigit(hours,   at: 1, w: digitW)
            flipColon(w: colonW, h: digitW * 1.3, color: onColor)
            flipDigit(minutes, at: 0, w: digitW)
            flipDigit(minutes, at: 1, w: digitW)
            flipColon(w: colonW, h: digitW * 1.3, color: onColor)
            flipDigit(seconds, at: 0, w: digitW * secScale)
            flipDigit(seconds, at: 1, w: digitW * secScale)
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func flipDigit(_ str: String, at index: Int, w: CGFloat) -> some View {
        let chars = Array(str)
        let ch: Character = chars.indices.contains(index) ? chars[index] : "0"
        FlipDigit(char: ch, onColor: onColor, width: w)
    }

    @ViewBuilder
    private func flipColon(w: CGFloat, h: CGFloat, color: Color) -> some View {
        VStack(spacing: h * 0.2) {
            Circle().fill(color).frame(width: w * 0.7, height: w * 0.7)
            Circle().fill(color).frame(width: w * 0.7, height: w * 0.7)
        }
        .frame(width: w, height: h)
    }
}

// MARK: - Dígito flip individual

struct FlipDigit: View {
    let char: Character
    let onColor: Color
    let width: CGFloat
    var height: CGFloat { width * 1.3 }

    private let cardBg   = Color(red: 0.14, green: 0.14, blue: 0.16)
    private let shadowBg = Color(red: 0.08, green: 0.08, blue: 0.10)

    @State private var displayed: Character
    @State private var upcoming:  Character
    @State private var foldAngle:   Double = 0
    @State private var unfoldAngle: Double = 0
    @State private var showUnfold:  Bool   = false
    @State private var bottomIsNew: Bool   = false
    @State private var busy: Bool = false

    init(char: Character, onColor: Color, width: CGFloat) {
        self.char = char; self.onColor = onColor; self.width = width
        _displayed = State(initialValue: char)
        _upcoming  = State(initialValue: char)
    }

    var body: some View {
        ZStack(alignment: .top) {
            // — Metade inferior (fixa)
            bottomHalf(char: bottomIsNew ? upcoming : displayed)
                .offset(y: height / 2 + 1)

            // — Metade superior fixa (char atual, oculta durante animação)
            topHalf(char: displayed)
                .opacity(busy ? 0 : 1)

            // — Peça a dobrar (char antigo a sair)
            topHalf(char: displayed)
                .rotation3DEffect(.degrees(foldAngle),
                                  axis: (x: 1, y: 0, z: 0),
                                  anchor: .bottom, perspective: 0.45)
                .opacity(busy && !showUnfold ? 1 : 0)

            // — Peça a desdobrar (char novo a entrar)
            topHalf(char: upcoming)
                .rotation3DEffect(.degrees(unfoldAngle),
                                  axis: (x: 1, y: 0, z: 0),
                                  anchor: .bottom, perspective: 0.45)
                .opacity(showUnfold ? 1 : 0)

            // — Linha divisória
            Rectangle()
                .fill(Color.black.opacity(0.55))
                .frame(width: width, height: 1.5)
                .offset(y: height / 2)
        }
        .frame(width: width, height: height)
        // Sombra exterior
        .shadow(color: .black.opacity(0.45), radius: 4, x: 0, y: 3)
        .onChange(of: char) { newChar in
            guard newChar != displayed, !busy else { return }
            upcoming = newChar
            busy     = true

            // Fase 1 — metade superior dobra para longe
            withAnimation(.linear(duration: 0.16)) { foldAngle = -90 }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                bottomIsNew  = true      // inferior muda imediatamente
                showUnfold   = true      // ativa peça nova
                unfoldAngle  = 90        // começa de trás do plano

                // Fase 2 — nova metade desdobra para a frente
                withAnimation(.linear(duration: 0.16)) { unfoldAngle = 0 }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                    displayed    = newChar
                    foldAngle    = 0
                    showUnfold   = false
                    bottomIsNew  = false
                    busy         = false
                }
            }
        }
    }

    // MARK: - Metades do cartão

    private func topHalf(char: Character) -> some View {
        ZStack {
            cardBg
            Text(String(char))
                .font(.system(size: width * 0.72, weight: .bold, design: .monospaced))
                .foregroundColor(onColor)
                .offset(y: height * 0.25)    // centra no cartão completo → mostra metade de cima
            // Degradé de sombra no topo
            LinearGradient(colors: [Color.black.opacity(0.18), .clear],
                           startPoint: .top, endPoint: .bottom)
        }
        .frame(width: width, height: height / 2)
        .clipShape(RoundedCornerShape(radius: 7, corners: [.topLeft, .topRight]))
    }

    private func bottomHalf(char: Character) -> some View {
        ZStack {
            shadowBg
            Text(String(char))
                .font(.system(size: width * 0.72, weight: .bold, design: .monospaced))
                .foregroundColor(onColor.opacity(0.85))
                .offset(y: -height * 0.25)   // mostra metade de baixo
            // Degradé de sombra em baixo
            LinearGradient(colors: [.clear, Color.black.opacity(0.22)],
                           startPoint: .top, endPoint: .bottom)
        }
        .frame(width: width, height: height / 2)
        .clipShape(RoundedCornerShape(radius: 7, corners: [.bottomLeft, .bottomRight]))
    }
}

// MARK: - Shape com cantos selecionados

struct RoundedCornerShape: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
