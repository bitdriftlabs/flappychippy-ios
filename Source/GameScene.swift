import GameplayKit
import SpriteKit

enum Body {
    static let chippy: UInt32 = 0x1 << 0
    static let ground: UInt32 = 0x1 << 1
    static let log: UInt32 = 0x1 << 2
    static let score: UInt32 = 0x1 << 3
}

enum LayerPriority {
    static let background = -10.0
    static let ground = -6.0
    static let title = -4.0
    static let chippy = -5.0
    static let buttons = 0.0
    static let panels = 1.0
    static let log = -8.0
    static let flash = 10.0
}

private enum GameState {
    case playing, gameover, taptap, onboarding
}

final class GameScene: SKScene {
    private lazy var bgNode = self.childNode(withName: "//background") as! BackgroundNode
    private lazy var chippy = self.childNode(withName: "//chippy") as! ChippyNode
    private lazy var logs = self.childNode(withName: "//logs")!
    private lazy var taptap = self.childNode(withName: "//taptap") as! SKSpriteNode
    private lazy var getReady = self.childNode(withName: "//get-ready") as! SKSpriteNode
    private lazy var scoreLabel = self.childNode(withName: "//score") as! LabelWithShadowNode
    private lazy var gameOver = self.childNode(withName: "//game-over") as! SKSpriteNode

    private var onboarding: OnboardingNode?
    private var touchedButton: ButtonNode?
    private var state: GameState = .onboarding
    private var score = 0 {
        didSet { self.scoreLabel.text = "\(self.score)" }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        let ref = self.childNode(withName: "//onboarding")
        self.onboarding = ref?.childNode(withName: "//root") as? OnboardingNode
        self.onboarding?.removeFromParent()
        ref?.removeFromParent()

        if let onboarding = self.onboarding {
            self.addChild(onboarding)
        }
    }

    override func didMove(to view: SKView) {
        self.gameOver.removeFromParent()
        self.bgNode.setupNodes(in: self)
        self.bgNode.loop()
        self.chippy.flap()
        self.chippy.float()
        self.chippy.position.x = 0
        self.scoreLabel.removeFromParent()
        self.taptap.removeFromParent()
        self.getReady.removeFromParent()
        self.physicsWorld.contactDelegate = self
    }

    override func update(_ currentTime: TimeInterval) {
        guard let velocity = self.chippy.physicsBody?.velocity else {
            return
        }

        let rotation = min(
            max(kMinChippyAngle, velocity.dy * (velocity.dy < 0.4 ? 0.003 : 0.001)), kMaxChippyAngle
        )
        let rotationPercent = (rotation - kMinChippyAngle) / (kMaxChippyAngle - kMinChippyAngle)
        self.chippy.run(.rotate(toAngle: rotation, duration: 0.1))
        self.chippy.speed = 1 + rotationPercent
    }

    private func showTapTap() {
        self.state = .taptap
        self.logs.children.forEach { $0.removeFromParent() }
        self.gameOver.animateOut()
        self.taptap.animateIn(in: self)
        self.getReady.animateIn(in: self)
        self.scoreLabel.animateIn(in: self)
        self.chippy.run(.move(to: CGPoint(x: -self.size.width / 4, y: 0), duration: 0.4))
        self.chippy.float()
        self.chippy.flap()
    }

    private func moveLogs() {
        let gapY = CGFloat.random(
            in: self.bgNode.groundY + kMinScreenPadding..<(self.size.height / 2) - kMinScreenPadding
        )
        let log = LogNode(gapAt: gapY)
        log.runMoveAnimation(size: self.size)
        self.logs.addChild(log)
    }

    private func startNewGame() {
        FlashNode(color: .black, in: self)
            .flash(fadeInDuration: 0.25, peakAlpha: 1.0, fadeOutDuration: 0.25)

        self.addChildIfOrphaned(self.logs)
        self.chippy.float(on: false)
        self.bgNode.loop()

        [self.taptap, self.getReady].forEach { $0.animateOut() }

        // Start moving logs from left to right
        self.run(
            .repeatForever(
                .sequence([
                    .run(moveLogs),
                    .wait(forDuration: kTimeDistanceBetweenLogs),
                ])
            ),
            withKey: "logs"
        )

        self.chippy.live()
        self.state = .playing
    }

    private func jump() {
        if self.state == .playing && self.chippy.position.y < (self.frame.height + 20) {
            self.chippy.jump()
        }
    }

    private func incrementScore() {
        self.score += 1
        self.scoreLabel.pop()
        Sound.point.play()
        Sound.impact.impactOccurred()
    }

    private func endGame() {
        if self.state != .playing { return }

        self.state = .gameover
        Sound.notification.notificationOccurred(.error)
        FlashNode(color: .white, in: self)
            .flash(fadeInDuration: 0.1, peakAlpha: 0.9, fadeOutDuration: 0.25)

        self.scoreLabel.animateOut()
        self.gameOver.animateIn(in: self)
        self.onboarding?.showScoresUI()

        self.bgNode.stop()
        self.logs.children.forEach { $0.removeAllActions() }
        self.removeAction(forKey: "logs")
        self.run(
            .sequence([
                .run(Sound.hit.play),
                .wait(forDuration: 0.3),
                .run(Sound.die.play),
            ])
        )

        self.score = 0
    }
}

// MARK: - Contact

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.category(is: Body.score) {
            self.incrementScore()
        } else if self.state == .playing && contact.category(is: Body.log) {
            self.endGame()
            self.chippy.fall()
        } else if contact.category(is: Body.ground) {
            self.endGame()
            self.chippy.die()
        }
    }
}

extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch self.state {
        case .playing: self.jump()
        case .taptap: self.startNewGame()
        case .gameover, .onboarding: break
        }
    }
}

extension GameScene: TouchReceiver {
    func onTouch(on button: ButtonNode) {
        let sceneButton = button.name.flatMap { SceneButton(rawValue: $0) }
        if sceneButton == .play {
            FlashNode(color: .white, in: self)
                .flash(fadeInDuration: 0.1, peakAlpha: 0.9, fadeOutDuration: 0.25)

            self.showTapTap()
        }
    }
}
