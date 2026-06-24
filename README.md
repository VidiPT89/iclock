# 🕐 iClock — Stylish Clock for iOS

> A SwiftUI clock app with four display styles and music integration.

Choose between 7-Segment (retro LED), Flip, Dot Matrix and Analog clock faces. Customise colour themes, switch between English and Portuguese, and control your music directly from the Now Playing bar — with Spotify and Apple Music support.

## 📦 What's Inside

- 🔢 Four clock styles — 7-Segment, Flip, Dot Matrix, Analog
- 🎨 Customisable colour themes
- 🌐 Bilingual support (English / Portuguese)
- 🎵 Now Playing bar with artwork and playback controls
- 🟢 Spotify integration via App Remote SDK
- 🍎 Apple Music fallback via MPNowPlayingInfoCenter
- 🔅 Auto-brightness dimming
- 🔒 Screen auto-lock disabled while active

## 🛠️ Tech Stack

![SwiftUI](https://img.shields.io/badge/SwiftUI-007AFF?style=flat&logo=swift&logoColor=white)
![AVFoundation](https://img.shields.io/badge/AVFoundation-000000?style=flat&logo=apple&logoColor=white)
![Combine](https://img.shields.io/badge/Combine-007AFF?style=flat&logo=apple&logoColor=white)
![Spotify SDK](https://img.shields.io/badge/Spotify_SDK-1DB954?style=flat&logo=spotify&logoColor=white)

## 🏗️ Architecture

```
├── ClockView               # Main clock container
├── ClockModel              # Clock state and logic
├── Clock Styles/
│   ├── SevenSegmentView
│   ├── FlipClockView
│   ├── DotMatrixView
│   └── AnalogClockView
├── NowPlayingManager       # Music playback info
├── SpotifyManager          # Spotify App Remote SDK
├── LanguageManager         # EN/PT localisation
└── SplashView              # Launch screen
```

## 🚀 How to Run

```bash
# 1. Clone the repository
git clone https://github.com/VidiPT89/iclock.git

# 2. Open in Xcode
open iclock.xcodeproj

# 3. (Optional) Configure Spotify SDK credentials

# 4. Build & run on a device or simulator (iOS 16+)
```

## 📝 Notes

- Requires iOS 16.0 or later
- Spotify features require the Spotify app installed on the device
- Apple Music works as a fallback without additional setup

---

Developed by **David Martins**
