import SwiftUI
import UIKit

// MARK: - AppDelegate: garante isIdleTimerDisabled desde o primeiro frame

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        application.isIdleTimerDisabled = true
        return true
    }

    // Restaura quando a app vai para segundo plano, reativa no regresso
    func applicationWillResignActive(_ application: UIApplication) {
        application.isIdleTimerDisabled = false
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.isIdleTimerDisabled = true
    }
}

// MARK: - Entry point

@main
struct iClockApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            SplashView()
                .preferredColorScheme(.dark)
                .onOpenURL { url in
                    // Callback de autorização do Spotify
                    SpotifyManager.shared.handleURL(url)
                }
        }
    }
}
