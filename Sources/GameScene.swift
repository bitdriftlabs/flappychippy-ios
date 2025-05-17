import Capture
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
    case playing
    case gameover
    case taptap
    case onboarding
}

final class GameScene: SKScene {
    // swiftlint:disable force_cast
    // swiftlint:disable force_unwrapping
    private lazy var logs = self.childNode(withName: "//logs")!
    private lazy var bgNode = self.childNode(withName: "//background") as! BackgroundNode
    private lazy var chippy = self.childNode(withName: "//chippy") as! ChippyNode
    private lazy var taptap = self.childNode(withName: "//taptap") as! SKSpriteNode
    private lazy var getReady = self.childNode(withName: "//get-ready") as! SKSpriteNode
    private lazy var scoreLabel = self.childNode(withName: "//score") as! LabelWithShadowNode
    private lazy var gameOver = self.childNode(withName: "//game-over") as! SKSpriteNode
    private lazy var onboarding = self.childNode(withName: "//onboarding") as! OnboardingNode
    // swiftlint:enable force_unwrapping
    // swiftlint:enable force_cast

    private let api = API(session: .shared)
    private var touchedButton: ButtonNode?
    private var state: GameState = .onboarding
    private var previousScore = 0
    private var score = 0 {
        didSet {
            self.previousScore = oldValue
            self.scoreLabel.text = "\(self.score)"
        }
    }

    override func didMove(to _: SKView) {
        self.gameOver.removeFromParent()
        self.bgNode.setupNodes(in: self)
        self.bgNode.loop()
        self.chippy.flap()
        self.chippy.float()
        self.chippy.position.x = 0
        self.scoreLabel.removeFromParent()
        self.taptap.removeFromParent()
        self.getReady.removeFromParent()
        self.onboarding.prefetchRanking()

        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: kGravityForce)
    }

    override func update(_: TimeInterval) {
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

    // MARK: - Private methods

    private func showTapTap() {
        Logger.logScreenView(screenName: "taptap")

        self.score = 0
        self.state = .taptap
        self.logs.children.forEach { $0.removeFromParent() }
        self.gameOver.animateOut()
        self.taptap.animateIn(in: self)
        self.getReady.animateIn(in: self)
        self.scoreLabel.animateIn(in: self)
        self.chippy.run(.move(to: CGPoint(x: -self.size.width / 4, y: 0), duration: 0.4))
        self.chippy.float()
        self.chippy.flap()
        self.bgNode.loop()
    }

    private func moveLogs() {
        let gapY = CGFloat.random(
            in: self.bgNode.groundY + kMinScreenPadding..<(self.size.height / 2) - kMinScreenPadding
        )

        let reducedGap = min((CGFloat(score) / 10.0) * 3, 12.0)
        LogNode(gapAt: gapY, gapHeight: kLogsGapHeight - reducedGap)
            .runMoveAnimation(in: self.logs, bounds: self.size)
    }

    private func startNewGame() {
        Logger.logInfo("Starting new game")
        Logger.startSpan(.game)
        Logger.startSpan(.beforeFirstLog, parent: .game)

        self.addChildIfOrphaned(self.logs)
        self.chippy.float(on: false)

        [self.taptap, self.getReady].forEach { $0.animateOut() }

        // Start moving logs from left to right
        self.run(
            .repeatForever(
                .sequence([
                    .run(self.moveLogs),
                    .wait(forDuration: kTimeDistanceBetweenLogs),
                ])
            ),
            withKey: "logs"
        )

        self.chippy.live()
        self.state = .playing
        self.jump()
    }

    private func jump() {
        if self.state == .playing && self.chippy.position.y < (self.frame.height + 20) {
            Sound.wing.play()
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
        if self.state != .playing {
            return
        }

        Logger.logInfo("Game over")
        Logger.endSpan(.game, result: .success)
        Logger.endSpan(.beforeFirstLog, result: .canceled)

        self.state = .gameover
        Sound.notification.notificationOccurred(.error)
        FlashNode(color: .white, in: self)
            .flash(fadeInDuration: 0.1, peakAlpha: 0.9, fadeOutDuration: 0.25)

        let finalScore = self.score
        self.scoreLabel.animateOut()
        self.gameOver.animateIn(in: self)

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

        let user = UserManager.shared.current
        if finalScore > user.best {
            Logger.logInfo(
                "User beat his best score", fields: ["score": finalScore, "best": user.best]
            )
            UserManager.shared.current = User(name: user.name, email: user.email, best: finalScore)
        }

        Task {
            try? await self.api.post(
                score: finalScore, name: user.name, email: user.email
            )
        }
    }
}

// MARK: - Contact

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let user = UserManager.shared.current
        if self.state == .playing && contact.category(is: Body.score) {
            self.incrementScore()
            Logger.endSpan(.beforeFirstLog, result: .success)
            Logger.endSpan(.jumping, result: .success)
            Logger.logInfo(
                "Chippy crossed a log", fields: ["score": self.score, "best_score": user.best]
            )

            Logger.startSpan(.jumping, parent: .game)
        } else if self.state == .playing && contact.category(is: Body.log) {
            self.endGame()
            self.chippy.fall()
        } else if contact.category(is: Body.ground) {
            self.endGame()
            self.chippy.die()
            self.onboarding.showScoresUI(best: user.best, score: self.score)
        }
    }
}

// MARK: - Touches

extension GameScene {
    override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
        switch self.state {
        case .playing: self.jump()
        case .taptap: self.startNewGame()
        case .gameover, .onboarding: break
        }
    }
}

extension GameScene: ButtonTouchReceiver {
    func onTouch(on button: ButtonNode) {
        let sceneButton = button.name.flatMap { SceneButton(rawValue: $0) }
        if sceneButton == .play {
            self.showTapTap()
        }
    }
}
