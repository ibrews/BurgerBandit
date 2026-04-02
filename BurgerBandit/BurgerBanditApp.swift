import SwiftUI

// Enforce landscape at the app delegate level — this is the only reliable way
// to force orientation with SwiftUI's WindowGroup.
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        .landscape
    }
}

@main
struct BurgerBanditApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            GameViewControllerRepresentable()
                .ignoresSafeArea()
                .statusBar(hidden: true)
        }
    }
}

struct GameViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> GameViewController {
        GameViewController()
    }
    func updateUIViewController(_ uiViewController: GameViewController, context: Context) {}
}
