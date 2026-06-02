import SwiftUI

struct SplashView: View {
    @State private var phase: Int = 0   // 0→1→2→3 (show main)
    @State private var showMain = false

    var body: some View {
        if showMain {
            ClockView()
                .transition(.opacity)
        } else {
            splash
                .onAppear {
                    UIApplication.shared.isIdleTimerDisabled = true
                    animate()
                }
        }
    }

    // MARK: - Splash

    private var splash: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.07).ignoresSafeArea()

            // Scanlines subtis
            RetroScanlines().ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Ícone / Logo
                ZStack {
                    // Halo
                    Circle()
                        .fill(amberColor.opacity(0.08))
                        .frame(width: 150, height: 150)
                        .blur(radius: 20)
                        .scaleEffect(phase >= 1 ? 1.0 : 0.4)
                        .opacity(phase >= 1 ? 1 : 0)

                    // Painel retro mini
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color(red: 0.06, green: 0.04, blue: 0.02))
                        .frame(width: 110, height: 110)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .strokeBorder(amberColor.opacity(0.25), lineWidth: 1)
                        )
                        .shadow(color: amberColor.opacity(0.3), radius: 20)

                    // Dígitos retro dentro do painel
                    VStack(spacing: 2) {
                        Text("00:00")
                            .font(.system(size: 32, weight: .black, design: .monospaced))
                            .foregroundColor(amberColor)
                            .shadow(color: amberColor.opacity(0.8), radius: 8)
                        Text("00")
                            .font(.system(size: 18, weight: .black, design: .monospaced))
                            .foregroundColor(amberColor.opacity(0.55))
                    }
                }
                .scaleEffect(phase >= 1 ? 1.0 : 0.55)
                .opacity(phase >= 1 ? 1.0 : 0)

                Spacer().frame(height: 36)

                // Nome da app
                Text("iClock")
                    .font(.system(size: 48, weight: .thin, design: .rounded))
                    .foregroundColor(.white)
                    .tracking(6)
                    .opacity(phase >= 2 ? 1.0 : 0)
                    .offset(y: phase >= 2 ? 0 : 12)

                Spacer().frame(height: 10)

                // Tagline
                Text("RETRO CLOCK")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(amberColor.opacity(0.7))
                    .tracking(5)
                    .opacity(phase >= 2 ? 1.0 : 0)

                Spacer()

                // Indicador de carregamento
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(amberColor)
                            .frame(width: 5, height: 5)
                            .opacity(phase >= 2 ? 1.0 : 0)
                            .scaleEffect(phase >= 2 ? 1.0 : 0.2)
                            .animation(
                                .easeInOut(duration: 0.5)
                                .repeatForever()
                                .delay(Double(i) * 0.18),
                                value: phase
                            )
                    }
                }
                .padding(.bottom, 20)

                // Créditos do criador
                VStack(spacing: 6) {
                    Text("developed by")
                        .font(.system(size: 10, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.20))
                        .tracking(2)
                        .textCase(.uppercase)
                    Text(Self.creatorName)
                        .font(.system(size: 13, weight: .light, design: .rounded))
                        .foregroundColor(.white.opacity(0.35))
                        .tracking(1)

                    // GitHub link
                    Link(destination: URL(string: Self.githubURL)!) {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left.forwardslash.chevron.right")
                                .font(.system(size: 9, weight: .medium))
                            Text(Self.githubHandle)
                                .font(.system(size: 10, weight: .regular, design: .monospaced))
                        }
                        .foregroundColor(amberColor.opacity(0.50))
                    }
                }
                .opacity(phase >= 2 ? 1.0 : 0)
                .padding(.bottom, 44)
            }
        }
        .preferredColorScheme(.dark)
    }

    private static let creatorName  = "David Arsénio Martins"
    private static let githubHandle = "github.com/VidiPT89"
    private static let githubURL    = "https://github.com/VidiPT89"

    private let amberColor = Color(red: 1.0, green: 0.60, blue: 0.08)

    // MARK: - Sequência de animação

    private func animate() {
        // Fase 1: ícone aparece
        withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) { phase = 1 }

        // Fase 2: texto aparece
        withAnimation(.easeOut(duration: 0.5).delay(0.6)) { phase = 2 }

        // Transição para a app principal
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
            withAnimation(.easeInOut(duration: 0.65)) { showMain = true }
        }
    }
}
