import GameplayKit
import SpriteKit
import UIKit

struct UserManager {
    static var shared: Self = .init()
    private let api = API(session: .shared)

    var loggedIn: Bool { self.current != nil }

    var current = Self.load() {
        didSet {
            UserDefaults.standard.set(self.current?.email, forKey: "email")
            UserDefaults.standard.set(self.current?.name, forKey: "name")
            UserDefaults.standard.set(self.current?.best ?? 0, forKey: "best")
        }
    }

    mutating func register(name: String, email: String) async {
        let result = try? await self.api.register(email: email, name: name)
        if result?.ok == true {
            self.current = User(name: name, email: email, best: 0)
        }
    }

    private static func load() -> User? {
        let best = UserDefaults.standard.integer(forKey: "best")
        guard
            let name = UserDefaults.standard.string(forKey: "name"),
            let email = UserDefaults.standard.string(forKey: "email")
        else {
            return nil
        }

        return User(name: name, email: email, best: best)
    }
}

class GameViewController: UIViewController {
    @IBOutlet private var backdrop: UIView!
    @IBOutlet private var registrationModal: UIView!
    @IBOutlet private var emailLabel: UITextField!
    @IBOutlet private var nameLabel: UITextField!
    @IBOutlet private var submitButton: UIButton!

    private let api = API(session: .shared)

    override func viewDidLoad() {
        super.viewDidLoad()

        if UserManager.shared.loggedIn {
            self.backdrop.removeFromSuperview()
            self.registrationModal.removeFromSuperview()
        }

        if let view = self.view as? SKView {
            if let scene = SKScene(fileNamed: "GameScene") {
                scene.scaleMode = .aspectFill
                view.presentScene(scene)
            }

            view.ignoresSiblingOrder = true
            view.showsFPS = false
            view.showsNodeCount = false
            view.showsPhysics = true
        }
    }

    @IBAction
    private func keyUp() {
        let valid = !(emailLabel.text ?? "").isEmpty && !(nameLabel.text ?? "").isEmpty
        self.submitButton.isEnabled = valid
    }

    @IBAction
    private func swoosh() {
        Sound.swoosh.play()
    }

    @IBAction
    private func register() {
        let email = self.emailLabel.text ?? ""
        let name = self.nameLabel.text ?? ""
        Task {
            let result = try? await self.api.register(email: email, name: name)
            if result?.ok == true {
                UserManager.shared.current = User(name: name, email: email, best: 0)
            }
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
            })
    }
}
