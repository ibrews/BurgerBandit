import UIKit
import SpriteKit

class GameViewController: UIViewController {

    private var scenePresented = false

    override func loadView() {
        let skView = SKView()
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.ignoresSiblingOrder = true
        view = skView
    }

    // Present the scene here — after Auto Layout has given the view its real frame.
    // viewDidLoad fires before the view is sized; viewDidLayoutSubviews fires after.
    // We wait until the bounds are actually landscape — the first call may fire
    // in portrait before the orientation rotation completes.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !scenePresented, let skView = view as? SKView else { return }

        // Don't create the scene until we have real landscape dimensions.
        let size = skView.bounds.size
        guard size.width > size.height, size.width > 100 else { return }

        scenePresented = true
        let scene = MainMenuScene(size: size)
        scene.scaleMode = .resizeFill   // view IS the scene — no scaling needed
        skView.presentScene(scene)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }
    override var prefersStatusBarHidden: Bool { true }
    override var prefersHomeIndicatorAutoHidden: Bool { true }
}
