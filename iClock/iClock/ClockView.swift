import SwiftUI
import MediaPlayer

struct ClockView: View {
    @StateObject private var clockModel = ClockModel()
    @ObservedObject private var languageManager = LanguageManager.shared
    @ObservedObject private var nowPlaying = NowPlayingManager.shared
    @AppStorage("selectedThemeId") private var selectedThemeId: String = ClockTheme.default.id
    @AppStorage("selectedStyleId") private var selectedStyleId: String = ClockStyle.segments.rawValue

    @State private var showPicker = false
    @State private var pickerTab: PickerTab = .style
    @State private var originalBrightness: CGFloat = UIScreen.main.brightness

    private var theme: ClockTheme { ClockTheme.find(id: selectedThemeId) }
    private var style: ClockStyle { ClockStyle(rawValue: selectedStyleId) ?? .segments }
    private var lang: AppLanguage { languageManager.language }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.09).ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // Data
                    Text(clockModel.dateString)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.38))
                        .textCase(.uppercase)
                        .tracking(3)
                        .padding(.bottom, 24)

                    // Relógio — estilo selecionado
                    clockFace(geo: geo)

                    Spacer()

                    // Frase
                    Text(clockModel.dailyPhrase)
                        .font(.system(size: 15, weight: .light, design: .rounded))
                        .foregroundColor(.white.opacity(0.32))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 36)
                        .padding(.bottom, nowPlaying.isVisible ? 12 : 52)

                    // Barra de música (Spotify / Apple Music)
                    if nowPlaying.isVisible {
                        NowPlayingBar()
                            .padding(.bottom, 52)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }

                // Botão de personalização
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                showPicker.toggle()
                            }
                        } label: {
                            Image(systemName: showPicker ? "xmark" : "slider.horizontal.3")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(showPicker ? theme.onColor : .white.opacity(0.45))
                                .padding(13)
                                .background(Color(white: 0.14))
                                .clipShape(Circle())
                                .shadow(color: showPicker ? theme.onColor.opacity(0.4) : .clear, radius: 8)
                        }
                        .padding(.top, 56)
                        .padding(.trailing, 20)
                    }
                    Spacer()
                }

                // Painel de personalização
                if showPicker {
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) { showPicker = false }
                        }
                    VStack {
                        Spacer()
                        CustomiserPanel(
                            tab: $pickerTab,
                            selectedStyleId: $selectedStyleId,
                            selectedThemeId: $selectedThemeId,
                            lang: lang
                        )
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(20)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            originalBrightness = UIScreen.main.brightness
            dimScreen()
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            UIScreen.main.brightness = originalBrightness
        }
        // App vai para segundo plano → restaura brilho
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            UIScreen.main.brightness = originalBrightness
        }
        // App volta ao primeiro plano → dim novamente
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            originalBrightness = UIScreen.main.brightness
            dimScreen()
        }
    }

    // MARK: - Brilho

    /// Reduz o brilho para ~70 % — horas visíveis, ecrã confortável no escuro
    private func dimScreen() {
        let target = max(originalBrightness * 0.70, 0.30)
        UIScreen.main.brightness = target
    }

    // MARK: - Cara do relógio

    @ViewBuilder
    private func clockFace(geo: GeometryProxy) -> some View {
        let w    = geo.size.width
        let wPad = w - 32   // subtrai 16 px de cada lado (padding dos painéis)
        switch style {
        case .segments:
            retroPanel(screenWidth: wPad)
        case .flip:
            flipPanel(screenWidth: wPad)
        case .dots:
            dotsPanel(screenWidth: wPad)
        case .analog:
            analogPanel(screenWidth: w)   // analógico não tem padding lateral
        }
    }

    // — 7 Segmentos

    @ViewBuilder
    private func retroPanel(screenWidth: CGFloat) -> some View {
        let spacing: CGFloat    = 5
        let hPad: CGFloat       = 20
        let colonRatio: CGFloat = 0.36
        let secScale: CGFloat   = 0.84
        let totalUnits = 4.0 + 2.0 * secScale + 2.0 * colonRatio
        let digitW     = (screenWidth - hPad * 2 - 6 * spacing) / totalUnits
        let digitH     = digitW * 1.9

        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(red: 0.06, green: 0.04, blue: 0.02))
                .shadow(color: .black.opacity(0.5), radius: 14, x: 0, y: 6)
            RetroScanlines()
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            HStack(spacing: spacing) {
                segDigit(clockModel.hours,   at: 0, w: digitW)
                segDigit(clockModel.hours,   at: 1, w: digitW)
                SevenSegmentColon(onColor: theme.onColor, offColor: theme.offColor,
                                  digitWidth: digitW, blink: clockModel.colonVisible)
                segDigit(clockModel.minutes, at: 0, w: digitW)
                segDigit(clockModel.minutes, at: 1, w: digitW)
                SevenSegmentColon(onColor: theme.onColor, offColor: theme.offColor,
                                  digitWidth: digitW, blink: clockModel.colonVisible)
                segDigit(clockModel.seconds, at: 0, w: digitW * secScale, dimmed: true)
                segDigit(clockModel.seconds, at: 1, w: digitW * secScale, dimmed: true)
            }
            .padding(.horizontal, hPad)
        }
        .frame(height: digitH + 32)
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func segDigit(_ str: String, at index: Int, w: CGFloat, dimmed: Bool = false) -> some View {
        let ch: Character = Array(str).indices.contains(index) ? Array(str)[index] : "0"
        SevenSegmentDigit(char: ch,
                          onColor: dimmed ? theme.onColor.opacity(0.62) : theme.onColor,
                          offColor: theme.offColor, width: w, glow: true)
    }

    // — Flip

    @ViewBuilder
    private func flipPanel(screenWidth: CGFloat) -> some View {
        let sampleW = computeFlipDigitW(screenWidth)
        let panelH  = sampleW * 1.3 + 24

        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(white: 0.08))
                .shadow(color: .black.opacity(0.5), radius: 14, x: 0, y: 6)

            FlipClockView(hours: clockModel.hours, minutes: clockModel.minutes,
                          seconds: clockModel.seconds,
                          onColor: theme.onColor, screenWidth: screenWidth)
        }
        .frame(height: panelH)
        .padding(.horizontal, 16)
    }

    private func computeFlipDigitW(_ sw: CGFloat) -> CGFloat {
        let spacing: CGFloat = 6
        let colonW:  CGFloat = 14
        let secScale: CGFloat = 0.82
        let units = 4.0 + 2.0 * secScale + 2.0 * (colonW / 56)
        let totalSpacing = 6.0 * spacing
        return (sw - totalSpacing) / units
    }

    // — Pontos

    @ViewBuilder
    private func dotsPanel(screenWidth: CGFloat) -> some View {
        let step = (screenWidth - 32) / (CGFloat(6 * 5 + 2) + 6 * 2) * 1.0
        let dotSize = step * 0.62
        let dotH    = dotSize * 7 + 2.5 * 6
        let panelH  = dotH + 28

        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(red: 0.04, green: 0.04, blue: 0.06))
                .shadow(color: .black.opacity(0.5), radius: 14, x: 0, y: 6)
            RetroScanlines()
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            DotMatrixClockView(
                hours: clockModel.hours, minutes: clockModel.minutes,
                seconds: clockModel.seconds, colonVisible: clockModel.colonVisible,
                onColor: theme.onColor, screenWidth: screenWidth
            )
        }
        .frame(height: panelH)
        .padding(.horizontal, 16)
    }

    // — Analógico

    @ViewBuilder
    private func analogPanel(screenWidth: CGFloat) -> some View {
        let diameter = min(screenWidth - 40, 320.0)

        ZStack {
            Circle()
                .fill(Color(white: 0.08))
                .shadow(color: .black.opacity(0.5), radius: 16, x: 0, y: 6)

            AnalogClockView(
                hours: clockModel.hours, minutes: clockModel.minutes,
                seconds: clockModel.seconds, onColor: theme.onColor,
                size: diameter - 12
            )
        }
        .frame(width: diameter, height: diameter)
    }
}

// MARK: - Painel de personalização

enum PickerTab { case style, theme, language }

struct CustomiserPanel: View {
    @Binding var tab: PickerTab
    @Binding var selectedStyleId: String
    @Binding var selectedThemeId: String
    let lang: AppLanguage

    var body: some View {
        VStack(spacing: 0) {
            // Tabs
            HStack(spacing: 0) {
                tabButton(
                    lang == .english ? "Style"    : "Estilo",
                    icon: "rectangle.3.group",
                    selected: tab == .style
                ) { withAnimation(.easeInOut(duration: 0.2)) { tab = .style } }

                tabButton(
                    lang == .english ? "Color"    : "Cor",
                    icon: "paintpalette.fill",
                    selected: tab == .theme
                ) { withAnimation(.easeInOut(duration: 0.2)) { tab = .theme } }

                tabButton(
                    lang == .english ? "Language" : "Idioma",
                    icon: "globe",
                    selected: tab == .language
                ) { withAnimation(.easeInOut(duration: 0.2)) { tab = .language } }
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)

            Divider().background(Color.white.opacity(0.08)).padding(.top, 12)

            // Conteúdo
            switch tab {
            case .style:    styleGrid
            case .theme:    themeRow
            case .language: languageRow
            }
        }
        // Rodapé GitHub
        Divider().background(Color.white.opacity(0.06))

        Link(destination: URL(string: "https://github.com/VidiPT89")!) {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .font(.system(size: 10, weight: .medium))
                Text("github.com/VidiPT89")
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
            }
            .foregroundColor(.white.opacity(0.22))
        }
        .padding(.top, 10)
        .padding(.bottom, 36)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(red: 0.10, green: 0.10, blue: 0.12))
                .shadow(color: .black.opacity(0.6), radius: 24, x: 0, y: -4)
        )
    }

    private var styleGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(ClockStyle.allCases, id: \.rawValue) { s in
                StyleCard(style: s, isSelected: s.rawValue == selectedStyleId, lang: lang) {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedStyleId = s.rawValue }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }

    private var themeRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(ClockTheme.all) { t in
                    ThemeSwatch(theme: t, isSelected: t.id == selectedThemeId, lang: lang) {
                        withAnimation(.easeInOut(duration: 0.2)) { selectedThemeId = t.id }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 18)
    }

    private var languageRow: some View {
        HStack(spacing: 16) {
            ForEach(AppLanguage.allCases, id: \.rawValue) { language in
                LanguageButton(
                    language: language,
                    isSelected: language == LanguageManager.shared.language
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        LanguageManager.shared.setLanguage(language)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 22)
    }

    @ViewBuilder
    private func tabButton(_ title: String, icon: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 13))
                Text(title).font(.system(size: 12, weight: .medium, design: .rounded))
            }
            .foregroundColor(selected ? .white : .white.opacity(0.38))
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(
                selected
                    ? RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.1))
                    : nil
            )
        }
    }
}

// MARK: - Botão de idioma

struct LanguageButton: View {
    let language: AppLanguage
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(language.flag)
                    .font(.system(size: 36))
                    .scaleEffect(isSelected ? 1.12 : 1.0)
                    .shadow(color: isSelected ? .white.opacity(0.4) : .clear, radius: 8)

                Text(language.displayName)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular, design: .rounded))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.40))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? Color.white.opacity(0.12) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(isSelected ? Color.white.opacity(0.35) : .clear, lineWidth: 1)
                    )
            )
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Swatch de tema (círculo colorido)

struct ThemeSwatch: View {
    let theme: ClockTheme
    let isSelected: Bool
    let lang: AppLanguage
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(theme.onColor.opacity(0.15))
                    .frame(width: 52, height: 52)

                Circle()
                    .fill(theme.onColor)
                    .frame(width: 34, height: 34)
                    .shadow(color: theme.onColor.opacity(isSelected ? 0.9 : 0.3),
                            radius: isSelected ? 10 : 4)

                if isSelected {
                    Circle()
                        .strokeBorder(Color.white.opacity(0.9), lineWidth: 2)
                        .frame(width: 52, height: 52)
                }
            }
            .scaleEffect(isSelected ? 1.08 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
            .onTapGesture { onTap() }

            Text(theme.name(lang: lang))
                .font(.system(size: 10, weight: isSelected ? .semibold : .regular,
                              design: .rounded))
                .foregroundColor(isSelected ? theme.onColor : .white.opacity(0.40))
        }
    }
}

// MARK: - Card de estilo

struct StyleCard: View {
    let style: ClockStyle
    let isSelected: Bool
    let lang: AppLanguage
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                Image(systemName: style.icon)
                    .font(.system(size: 26))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.45))
                Text(style.name(lang: lang))
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular,
                                  design: .rounded))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.45))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? Color.white.opacity(0.12) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(isSelected ? Color.white.opacity(0.35) : .clear, lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Now Playing Bar (Spotify / Apple Music)

struct NowPlayingBar: View {
    @ObservedObject private var mgr     = NowPlayingManager.shared
    @ObservedObject private var spotify = SpotifyManager.shared
    private let amber = Color(red: 1.0, green: 0.60, blue: 0.08)
    private let green = Color(red: 0.12, green: 0.85, blue: 0.42)
    private var accent: Color { spotify.isConnected ? green : amber }

    var body: some View {
        HStack(spacing: 10) {

            // Artwork
            ZStack {
                if let img = mgr.artwork {
                    Image(uiImage: img).resizable().scaledToFill()
                } else {
                    accent.opacity(0.15)
                    Image(systemName: "music.note")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(accent.opacity(0.7))
                }
            }
            .frame(width: 34, height: 34)
            .clipShape(RoundedRectangle(cornerRadius: 7))

            // Título + artista
            VStack(alignment: .leading, spacing: 1) {
                Text(mgr.trackTitle.isEmpty ? "Music" : mgr.trackTitle)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(1)
                Text(mgr.artistName.isEmpty ? (spotify.isConnected ? "Spotify" : "Now Playing") : mgr.artistName)
                    .font(.system(size: 10, weight: .regular, design: .rounded))
                    .foregroundColor(accent.opacity(0.75))
                    .lineLimit(1)
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .layoutPriority(0)

            // ⏮  ⏸/▶  ⏭
            HStack(spacing: 2) {
                ctrlBtn("backward.fill")                            { mgr.previousTrack()   }
                ctrlBtn(mgr.isPlaying ? "pause.fill" : "play.fill") { mgr.togglePlayPause() }
                ctrlBtn("forward.fill")                             { mgr.nextTrack()        }
            }
            .layoutPriority(1)

            // Botão ligar Spotify (só quando SDK presente e desligado)
            if spotify.sdkAvailable && !spotify.isConnected {
                Button { spotify.connect() } label: {
                    Image(systemName: "link.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(green.opacity(0.75))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 0.09, green: 0.07, blue: 0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(accent.opacity(0.28), lineWidth: 1)
                )
                .shadow(color: accent.opacity(0.12), radius: 10)
        )
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func ctrlBtn(_ icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(accent)
        }
        .buttonStyle(.plain)
        .frame(width: 36, height: 36)
    }
}

// MARK: - Scanlines (partilhado)

struct RetroScanlines: View {
    var body: some View {
        Canvas { ctx, size in
            var y: CGFloat = 0
            while y < size.height {
                ctx.fill(Path(CGRect(x: 0, y: y, width: size.width, height: 1)),
                         with: .color(.black.opacity(0.12)))
                y += 3
            }
        }
        .allowsHitTesting(false)
    }
}
