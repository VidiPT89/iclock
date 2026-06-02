# 🕐 iClock

> A clock should feel like a clock. Not a notification tray with a time somewhere in the corner.

A SwiftUI clock app for iOS with four distinct display styles, music playback controls, and a screen that stays on — because a clock that locks itself isn't much of a clock.

---

## What's inside

- Four clock styles: 7-Segment (retro LED), Flip, Dot Matrix, and Analog
- Colour themes to match your mood or setup
- English and Portuguese language support
- Now Playing bar with artwork, track title, artist, and playback controls
- Full Spotify App Remote SDK integration — connect, play, pause, skip
- Apple Music / system player fallback via `MPNowPlayingInfoCenter`
- Auto-brightness dim when the app is in focus — easy on the eyes in the dark
- Screen auto-lock disabled while the app is open
- GitHub shortcut in the customiser panel, because why not

---

## Tech Stack

`SwiftUI` | `AVFoundation` | `MediaPlayer` | `Combine` | `SpotifyiOS SDK` | `UIKit`

---

## Architecture

```
iClock
├── ClockView          →  main view, all four clock faces, customiser panel
├── ClockModel         →  time ticking, date string, daily phrase
├── NowPlayingManager  →  music detection, playback controls, AVAudioSession
├── SpotifyManager     →  Spotify App Remote SDK, OAuth callback, player state
├── LanguageManager    →  English / Portuguese toggle with AppStorage
├── SplashView         →  launch screen with credits and GitHub link
└── Clock styles
    ├── SevenSegmentView   →  LED digit renderer with scanlines overlay
    ├── FlipClockView      →  split-flap digit animation
    ├── DotMatrixView      →  5×7 dot matrix LED grid
    └── AnalogClockView    →  hands with smooth second movement
```

---

## Screens

| Screen | Description |
|--------|-------------|
| 🟠 7-Segment | Retro LED display with scanline effect and glow |
| 🔄 Flip | Split-flap style with per-digit animation |
| 🔵 Dot Matrix | 5×7 LED grid — compact and clean |
| ⏱️ Analog | Classic hands with smooth sweep |
| 🎵 Now Playing | Slides up when music is detected — Spotify or Apple Music |
| 🎨 Customiser | Style, colour theme, and language picker |

---

## Spotify Integration

iClock uses the **Spotify App Remote SDK** for full playback control when Spotify is running:

- Connect button appears automatically when the SDK is present and Spotify is not linked
- Once connected: artwork, track title, artist, play/pause, and skip are all live
- When Spotify is not connected, the app falls back to the iOS system player via `MPNowPlayingInfoCenter`

> Requires a free Spotify Developer account and a registered redirect URI (`iclock://spotify-callback`).

---

## Requirements

- iOS 16+
- Xcode 15+
- Spotify account (optional — only needed for Spotify controls)

---

## Getting Started

```bash
git clone https://github.com/VidiPT89/iclock.git
```

1. Open `iClock.xcodeproj` in Xcode
2. Select your target device or simulator (iOS 16+)
3. Build and run

**Optional — Spotify support:**

1. Create an app at [developer.spotify.com](https://developer.spotify.com)
2. Add `iclock://spotify-callback` as a Redirect URI
3. Download `SpotifyiOS.xcframework` from the [Spotify iOS SDK releases](https://github.com/spotify/ios-sdk/releases)
4. Drag the `.xcframework` into the Xcode project (target → Frameworks)
5. Replace the Client ID in `SpotifyManager.swift`

The app compiles and runs without the SDK — Spotify features activate automatically when the framework is present.

---

## Honest notes

- This started as a simple clock and somehow grew a full music player. No regrets.
- The auto-brightness dim uses `UIScreen.main.brightness`, which Apple keeps threatening to deprecate. It works for now.
- The `AVAudioSession` interrupt trick for pausing non-Spotify players is a bit of a hack. It works. It feels wrong. It stays.
- Layout calculations are manual (`GeometryReader` + explicit widths) because SwiftUI's automatic sizing disagreed with the design vision more than once.

---

## Context

Built as a personal project during the iOS Mobile Development module at CESAE Digital.  
It started as a clock. It became a study in SwiftUI layout, audio sessions, and third-party SDK integration.

_The screen no longer locks itself. That alone was worth it._

---

<div align="center">
  <sub>developed by <a href="https://github.com/VidiPT89">David Arsénio Martins</a></sub>
</div>
