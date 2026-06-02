import Foundation
import UIKit

// ─────────────────────────────────────────────────────────────────────────────
//  SpotifyManager — Integração com o Spotify App Remote SDK
//
//  SETUP (uma vez, gratuito):
//  1. Cria uma app em developer.spotify.com  →  copia o Client ID
//  2. Adiciona  "iclock://spotify-callback"  como Redirect URI na dashboard
//  3. Transfere SpotifyiOS.xcframework de github.com/spotify/ios-sdk/releases
//  4. Arrasta o .xcframework para o Xcode (target iClock → Frameworks)
//  5. Cola o teu Client ID em `clientID` abaixo
//  6. Compila — tudo o resto funciona automaticamente
// ─────────────────────────────────────────────────────────────────────────────

#if canImport(SpotifyiOS)
import SpotifyiOS
#endif

class SpotifyManager: NSObject, ObservableObject {
    static let shared = SpotifyManager()

    // ⚠️  Cola aqui o teu Client ID do developer.spotify.com
    private static let clientID    = "d92edcc6095749c3987c7d790fc18be0"
    private static let redirectURI = URL(string: "iclock://spotify-callback")!

    // Estado público
    @Published var isConnected  = false
    @Published var isPlaying    = false
    @Published var trackName    = ""
    @Published var artistName   = ""
    @Published var albumArt: UIImage?

    /// true quando o SpotifyiOS.xcframework está no projeto
    var sdkAvailable: Bool {
        #if canImport(SpotifyiOS)
        return true
        #else
        return false
        #endif
    }

    #if canImport(SpotifyiOS)
    private lazy var appRemote: SPTAppRemote = {
        let cfg = SPTConfiguration(clientID: SpotifyManager.clientID,
                                   redirectURL: SpotifyManager.redirectURI)
        let remote = SPTAppRemote(configuration: cfg, logLevel: .none)
        remote.delegate = self
        return remote
    }()
    #endif

    private override init() { super.init() }

    // MARK: – Ligação

    /// Abre o Spotify para autorização (ou instala se não estiver presente)
    func connect() {
        #if canImport(SpotifyiOS)
        guard !appRemote.isConnected else { return }
        appRemote.authorizeAndPlayURI("", asRadio: false)
        #endif
    }

    /// Chama-se em onOpenURL — processa o callback de autorização
    @discardableResult
    func handleURL(_ url: URL) -> Bool {
        #if canImport(SpotifyiOS)
        guard let params = appRemote.authorizationParameters(from: url) else {
            return false
        }
        if let token = params[SPTAppRemoteAccessTokenKey] as? String {
            appRemote.connectionParameters.accessToken = token
            appRemote.connect()
            return true
        }
        #endif
        return false
    }

    func disconnect() {
        #if canImport(SpotifyiOS)
        if appRemote.isConnected { appRemote.disconnect() }
        #endif
        DispatchQueue.main.async {
            self.isConnected = false
            self.isPlaying   = false
        }
    }

    // MARK: – Controlos de reprodução

    func play()  {
        #if canImport(SpotifyiOS)
        appRemote.playerAPI?.resume(nil)
        #endif
        DispatchQueue.main.async { self.isPlaying = true }
    }
    func pause() {
        #if canImport(SpotifyiOS)
        appRemote.playerAPI?.pause(nil)
        #endif
        DispatchQueue.main.async { self.isPlaying = false }
    }
    func togglePlayPause() { isPlaying ? pause() : play() }
    func nextTrack() {
        #if canImport(SpotifyiOS)
        appRemote.playerAPI?.skip(toNext: nil)
        #endif
    }
    func previousTrack() {
        #if canImport(SpotifyiOS)
        appRemote.playerAPI?.skip(toPrevious: nil)
        #endif
    }
}

// MARK: – SPTAppRemoteDelegate

#if canImport(SpotifyiOS)
extension SpotifyManager: SPTAppRemoteDelegate {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        DispatchQueue.main.async { self.isConnected = true }
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { _, _ in })
        // Pede o estado atual logo ao ligar
        appRemote.playerAPI?.getPlayerState { [weak self] state, _ in
            guard let state = state as? SPTAppRemotePlayerState else { return }
            self?.playerStateDidChange(state)
        }
    }

    func appRemote(_ appRemote: SPTAppRemote,
                   didDisconnectWithError error: Error?) {
        DispatchQueue.main.async { self.isConnected = false; self.isPlaying = false }
    }

    func appRemote(_ appRemote: SPTAppRemote,
                   didFailConnectionAttemptWithError error: Error?) {
        DispatchQueue.main.async { self.isConnected = false }
    }
}

// MARK: – SPTAppRemotePlayerStateDelegate

extension SpotifyManager: SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        DispatchQueue.main.async {
            self.isPlaying  = !playerState.isPaused
            self.trackName  = playerState.track.name
            self.artistName = playerState.track.artist.name
        }
        // Artwork
        appRemote.imageAPI?.fetchImage(
            forItem: playerState.track,
            with: CGSize(width: 80, height: 80)
        ) { [weak self] image, _ in
            DispatchQueue.main.async { self?.albumArt = image as? UIImage }
        }
    }
}
#endif
