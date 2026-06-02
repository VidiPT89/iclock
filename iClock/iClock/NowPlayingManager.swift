import Foundation
import MediaPlayer
import AVFoundation
import Combine

class NowPlayingManager: ObservableObject {
    static let shared = NowPlayingManager()

    @Published var isVisible    = false
    @Published var isPlaying    = false
    @Published var trackTitle   = ""
    @Published var artistName   = ""
    @Published var artwork: UIImage?

    private var pollTimer: AnyCancellable?
    private var weInterrupted  = false
    private var spotifyCancellables = Set<AnyCancellable>()

    private init() {
        setupAudioSession()
        startPolling()
        observeSpotify()
    }

    // MARK: – Audio session (ambient — nunca interrompe o Spotify sozinho)

    private func setupAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    // MARK: – Sincronização com SpotifyManager

    private func observeSpotify() {
        let spotify = SpotifyManager.shared

        spotify.$isConnected
            .receive(on: RunLoop.main)
            .sink { [weak self] connected in
                if connected { self?.weInterrupted = false }
                if !connected { self?.poll() }
            }
            .store(in: &spotifyCancellables)

        spotify.$isPlaying
            .receive(on: RunLoop.main)
            .sink { [weak self] playing in
                guard SpotifyManager.shared.isConnected else { return }
                self?.isPlaying = playing
            }
            .store(in: &spotifyCancellables)

        spotify.$trackName
            .receive(on: RunLoop.main)
            .sink { [weak self] name in
                guard SpotifyManager.shared.isConnected else { return }
                self?.trackTitle = name
                self?.isVisible  = !name.isEmpty
            }
            .store(in: &spotifyCancellables)

        spotify.$artistName
            .receive(on: RunLoop.main)
            .sink { [weak self] artist in
                guard SpotifyManager.shared.isConnected else { return }
                self?.artistName = artist
            }
            .store(in: &spotifyCancellables)

        spotify.$albumArt
            .receive(on: RunLoop.main)
            .sink { [weak self] art in
                guard SpotifyManager.shared.isConnected else { return }
                self?.artwork = art
            }
            .store(in: &spotifyCancellables)
    }

    // MARK: – Polling (fallback quando Spotify SDK não está ligado)

    private func startPolling() {
        pollTimer = Timer.publish(every: 1.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard !SpotifyManager.shared.isConnected else { return }
                self?.poll()
            }
    }

    private func poll() {
        let session  = AVAudioSession.sharedInstance()
        let isOther  = session.isOtherAudioPlaying || weInterrupted

        let info     = MPNowPlayingInfoCenter.default().nowPlayingInfo
        let title    = info?[MPMediaItemPropertyTitle]  as? String ?? ""
        let artist   = info?[MPMediaItemPropertyArtist] as? String ?? ""
        let rate     = info?[MPNowPlayingInfoPropertyPlaybackRate] as? Double

        isVisible  = isOther || !title.isEmpty
        trackTitle = title
        artistName = artist

        if !weInterrupted {
            if let r = rate { isPlaying = r > 0 } else { isPlaying = isOther }
        }

        if let item = info?[MPMediaItemPropertyArtwork] as? MPMediaItemArtwork {
            artwork = item.image(at: CGSize(width: 60, height: 60))
        } else if !isVisible {
            artwork = nil
        }
    }

    // MARK: – Controlos

    func togglePlayPause() { isPlaying ? pause() : resume() }

    func pause() {
        if SpotifyManager.shared.isConnected {
            SpotifyManager.shared.pause(); return
        }
        weInterrupted = true
        isPlaying     = false
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func resume() {
        if SpotifyManager.shared.isConnected {
            SpotifyManager.shared.play(); return
        }
        weInterrupted = false
        isPlaying     = true
        try? AVAudioSession.sharedInstance()
            .setActive(false, options: .notifyOthersOnDeactivation)
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func nextTrack() {
        if SpotifyManager.shared.isConnected {
            SpotifyManager.shared.nextTrack(); return
        }
        MPMusicPlayerController.systemMusicPlayer.skipToNextItem()
    }

    func previousTrack() {
        if SpotifyManager.shared.isConnected {
            SpotifyManager.shared.previousTrack(); return
        }
        MPMusicPlayerController.systemMusicPlayer.skipToPreviousItem()
    }
}
