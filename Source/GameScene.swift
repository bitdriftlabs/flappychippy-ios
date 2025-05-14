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
    case playing, gameover, taptap
}

final class GameScene: SKScene {
    private lazy var bgNode = self.childNode(withName: "//background") as! BackgroundNode
    private lazy var chippy = self.childNode(withName: "//chippy") as! ChippyNode
    private lazy var logs = self.childNode(withName: "//logs")!
    private lazy var taptap = self.childNode(withName: "//taptap") as! SKSpriteNode
    private lazy var getReady = self.childNode(withName: "//get-ready") as! SKSpriteNode
    private lazy var scoreLabel = self.childNode(withName: "//score") as! LabelWithShadowNode
    private lazy var gameOver = self.childNode(withName: "//game-over") as! SKSpriteNode

    private var touchedButton: ButtonNode?
    private var state: GameState = .taptap
    private var score = 0

    override func didMove(to view: SKView) {
        self.gameOver.removeFromParent()
        self.bgNode.setupNodes(in: self)
        self.bgNode.loop()
        self.chippy.flap()
        self.chippy.float()
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

    private func moveLogs() {
        let gapY = CGFloat.random(
            in: self.bgNode.groundY + kMinScreenPadding..<(self.size.height / 2) - kMinScreenPadding
        )
        let log = LogNode(gapAt: gapY)
        log.position.x = self.size.width / 2

        let delta = log.position.x + log.width + (self.size.width / 2)
        let sequence = SKAction.sequence([
            SKAction.moveTo(
                x: -log.width - (self.size.width / 2), duration: kLogSecondsPerPixel * delta
            ),
            SKAction.moveTo(x: self.size.width / 2, duration: 0),
            SKAction.removeFromParent(),
        ])

        log.run(sequence)
        self.logs.addChild(log)
    }

    private func startNewGame() {
        self.score = 0
        FlashNode(color: .black, in: self)
            .flash(fadeInDuration: 0.25, peakAlpha: 1.0, fadeOutDuration: 0.25)

        self.addChildIfOrphaned(self.logs)
        self.chippy.float(on: false)

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
        self.scoreLabel.text = "\(self.score)"
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
        case .gameover: SKScene.present(named: "GameScene", from: self)
        case .taptap: self.startNewGame()
        }
    }
}

extension SKPhysicsContact {
    func category(is mask: UInt32) -> Bool {
        self.bodyA.categoryBitMask & mask == mask || self.bodyB.categoryBitMask & mask == mask
    }
}
