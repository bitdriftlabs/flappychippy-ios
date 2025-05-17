import Capture
import GameplayKit
import SpriteKit
import UIKit

class GameViewController: UIViewController {
    @IBOutlet private var backdrop: UIView!
    @IBOutlet private var registrationModal: UIView!
    @IBOutlet private var emailLabel: UITextField!
    @IBOutlet private var nameLabel: UITextField!
    @IBOutlet private var submitButton: UIButton!

    private let api = API(session: .shared)

    override func viewDidLoad() {
        super.viewDidLoad()
        Logger.logScreenView(screenName: "registration")
        Logger.startSpan(.onboarding)

        if UserManager.shared.loggedIn {
            self.backdrop.removeFromSuperview()
            self.registrationModal.removeFromSuperview()
            Logger.endSpan(.onboarding, result: .success)
            Logger.logScreenView(screenName: "landing")
        } else {
            Logger.startSpan(.registration, parent: .onboarding)
        }

        if let view = self.view as? SKView {
            if let scene = SKScene(fileNamed: "GameScene") {
                scene.scaleMode = .aspectFill
                view.presentScene(scene)
            }

            view.ignoresSiblingOrder = true
            view.showsFPS = false
            view.showsNodeCount = false
            view.showsPhysics = false
        }
    }

    // MARK: - Private methods

    @IBAction private func keyUp() {
        let valid = !(emailLabel.text ?? "").isEmpty && !(self.nameLabel.text ?? "").isEmpty
        self.submitButton.isEnabled = valid
    }

    @IBAction private func swoosh() {
        Sound.swoosh.play()
    }

    @IBAction private func register() {
        let email = self.emailLabel.text ?? ""
        let name = self.nameLabel.text ?? ""
        Logger.logDebug("User try to register")
        Task {
            Logger.startSpan(.registrationNetwork, parent: .onboarding)
            let result = try? await self.api.register(email: email, name: name)
            Logger.endSpan(.registrationNetwork, result: result == true ? .success : .failure)

            if result == true {
                UserManager.shared.current = User(name: name, email: email, best: 0)
            } else {
                Logger.logError("Registration failed")
            }

            Logger.endSpan(.registration, result: result == true ? .success : .failure)
            Logger.endSpan(.onboarding, result: .success)
        }

        UIView.animate(
            withDuration: 0.2,
            animations: {
                self.backdrop.alpha = 0.0
                self.registrationModal.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            },
            completion: { _ in
                self.registrationModal.removeFromSuperview()
                self.backdrop.removeFromSuperview()
            }
        )
    }
}
