# 🕐 iClock — Stylish Clock Faces with Music Integration for iOS

> A SwiftUI clock app with four visual styles, colour themes, bilingual support, and live Spotify + Apple Music playback.

Turn your iPhone into a beautiful desk clock with four distinct visual styles — retro 7-Segment LED with scanline glow effects, classic Flip split-flap digits with smooth animations, Dot Matrix with a 5×7 LED grid, and Analog with sweeping second hands. Customise the look with colour themes and switch between English and Portuguese. The Now Playing bar shows your current track with artwork, title, and artist, plus play/pause and skip controls. Connect to Spotify via the App Remote SDK for full playback control, or let Apple Music provide track info through MPNowPlayingInfoCenter. Auto-brightness dimming and screen auto-lock disable make it perfect for bedside or desk use.

## 📦 What's Inside

- 🔢 **7-Segment Style** — Retro LED display with authentic scanlines and glow effects
- 🔄 **Flip Clock Style** — Split-flap digit animation mimicking mechanical departure boards
- 💡 **Dot Matrix Style** — 5×7 LED grid rendering each digit with pixel precision
- 🕰️ **Analog Style** — Classic clock face with smooth sweep second hand
- 🎨 Colour themes to match your mood or room setup
- 🇬🇧🇵🇹 Bilingual interface — English and Portuguese via AppStorage
- 🎵 **Now Playing bar** — Album artwork, track title, artist name
- ▶️ Play/pause and skip controls in the Now Playing bar
- 🟢 **Spotify integration** — Connect via App Remote SDK with OAuth callback
- 🍎 **Apple Music fallback** — MPNowPlayingInfoCenter for current track info
- 🔅 Auto-brightness dimming for nightstand use
- 🔒 Screen auto-lock disabled — clock stays visible indefinitely
- 📅 Date display and daily phrase feature
- 🚀 Splash screen on launch

## 🛠️ Tech Stack

![SwiftUI](https://img.shields.io/badge/SwiftUI-0071E3?style=flat&logo=swift&logoColor=white)
![AVFoundation](https://img.shields.io/badge/AVFoundation-000000?style=flat&logo=apple&logoColor=white)
![MediaPlayer](https://img.shields.io/badge/MediaPlayer-000000?style=flat&logo=apple&logoColor=white)
![Combine](https://img.shields.io/badge/Combine-0071E3?style=flat&logo=apple&logoColor=white)
![Spotify SDK](https://img.shields.io/badge/Spotify_App_Remote_SDK-1DB954?style=flat&logo=spotify&logoColor=white)
![iOS](https://img.shields.io/badge/iOS_16+-000000?style=flat&logo=apple&logoColor=white)

## 🏗️ Architecture

```
iclock/
├── App/
│   ├── iClockApp.swift               # App entry point, Spotify OAuth URL handling
│   └── SplashView.swift              # Animated launch screen
├── Clock/
│   ├── ClockView.swift               # Main clock container, style switcher
│   ├── ClockModel.swift              # Time ticking, date formatting, daily phrase
│   ├── SevenSegmentView.swift        # 7-segment LED digits with scanline + glow
│   ├── FlipClockView.swift           # Split-flap flip animation per digit
│   ├── DotMatrixView.swift           # 5×7 LED grid rendering
│   └── AnalogClockView.swift         # Classic clock face with sweep hands
├── Music/
│   ├── NowPlayingManager.swift       # AVAudioSession + MPNowPlayingInfoCenter
│   └── SpotifyManager.swift          # Spotify App Remote SDK connection + playback
├── Settings/
│   └── LanguageManager.swift         # EN/PT toggle persisted with AppStorage
└── Resources/
    └── Assets.xcassets               # Colour themes, icons, splash assets
```

## 📱 Screens

| Screen | Description |
|--------|-------------|
| 🚀 **Splash** | Animated launch screen before entering the clock |
| 🔢 **7-Segment** | Retro LED time display with glowing segments and scanline overlay |
| 🔄 **Flip Clock** | Split-flap digits that animate on each second change |
| 💡 **Dot Matrix** | 5×7 pixel grid rendering time in LED dot style |
| 🕰️ **Analog** | Classic clock face with hour, minute, and smooth sweep second hands |
| 🎵 **Now Playing** | Persistent bar showing artwork, track, artist, and playback controls |
| ⚙️ **Settings** | Colour theme picker and EN/PT language toggle |

## 🔄 How It Works

1. **Time Engine** — `ClockModel` publishes the current time every second via Combine; all four clock views subscribe
2. **Style Switching** — `ClockView` holds the active style state; user swipes or taps to switch between the four faces
3. **Spotify Flow** — User taps Connect → Spotify app opens for OAuth → callback to `iclock://spotify-callback` → `SpotifyManager` establishes App Remote session
4. **Apple Music Fallback** — If Spotify is not connected, `NowPlayingManager` reads `MPNowPlayingInfoCenter` for the currently playing track
5. **Now Playing Bar** — Displays artwork, title, and artist from whichever source is active; controls send commands to `SpotifyManager` or system player
6. **Auto-Dim** — Screen brightness is reduced after a timeout; `UIApplication.shared.isIdleTimerDisabled = true` prevents auto-lock
7. **Language** — `LanguageManager` stores the selected locale in `AppStorage`; all UI text and the daily phrase update reactively

## 🚀 How to Run

```bash
# 1. Clone the repository
git clone https://github.com/VidiPT89/iclock.git

# 2. Open in Xcode
open iclock.xcodeproj

# 3. (Optional) Configure Spotify
#    Add your Spotify Client ID in SpotifyManager.swift
#    Ensure the redirect URI iclock://spotify-callback is registered in your Spotify Dashboard

# 4. Select an iOS 16+ simulator or device

# 5. Build and run (⌘R)
```

## 📝 Notes

- Spotify features require the **Spotify app installed** on the device and a **Spotify Developer account** for the Client ID
- Apple Music integration uses the system **MPNowPlayingInfoCenter** — it reads whatever is currently playing, no login required
- The `iclock://spotify-callback` custom URL scheme must be registered in the app's **Info.plist** for OAuth to complete
- Auto-lock is disabled using `UIApplication.shared.isIdleTimerDisabled` — this keeps the clock visible but may increase battery drain
- The 7-Segment view uses layered `Canvas` drawing with opacity modulation for the authentic **scanline and glow** effects
- All four clock styles share the same `ClockModel` data source, so switching styles is instant with no data re-fetch

---

Developed by **David Arsénio Martins** — *"Vidi"*
