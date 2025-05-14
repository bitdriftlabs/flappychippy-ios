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

struct CurrentGame {
    fileprivate var playing: Bool
    fileprivate var score: Int
}

final class GameScene: SKScene {
    private lazy var bgNode = self.childNode(withName: "//background") as! BackgroundNode
    private lazy var chippy = self.childNode(withName: "//chippy") as! ChippyNode
    private lazy var logs = self.childNode(withName: "//logs")!
    private lazy var taptap = self.childNode(withName: "//taptap") as! GameSpriteNode
    private lazy var getReady = self.childNode(withName: "//get-ready") as! GameSpriteNode
    private lazy var scoreLabel = self.childNode(withName: "//score-label") as! SKLabelNode
    private lazy var scoreShadowLabel = self.childNode(withName: "//score-shadow") as! SKLabelNode

    private var touchedButton: ButtonNode?
    private var game = CurrentGame(playing: false, score: 0) {
        didSet {
            self.scoreLabel.text = "\(self.game.score)"
            self.scoreShadowLabel.text = "\(self.game.score)"
        }
    }

    override func didMove(to view: SKView) {
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

    private func movePipes() {
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
        self.game = CurrentGame(playing: false, score: 0)
        FlashNode(color: .black, in: self)
            .flash(fadeInDuration: 0.25, peakAlpha: 1.0, fadeOutDuration: 0.25)

        self.addChildIfOrphaned(self.logs)
        self.chippy.float(on: false)

        [self.taptap, self.getReady].forEach { $0.animate(in: false) }

        // Start moving pipes from left to right
        self.run(
            .repeatForever(
                .sequence([
                    .run(movePipes),
                    .wait(forDuration: kTimeDistanceBetweenLogs),
                ])
            ),
            withKey: "pipes"
        )

        self.chippy.physicsBody?.isDynamic = true
        self.game.playing = true
    }

    private func jump() {
        if self.chippy.position.y < (self.frame.height + 20) {
            self.chippy.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            self.chippy.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 230))
        }
    }

    private func gameOver() {
        if !self.game.playing { return }

        self.game.playing = false
        Sound.notification.notificationOccurred(.error)
        FlashNode(color: .white, in: self)
            .flash(fadeInDuration: 0.1, peakAlpha: 0.9, fadeOutDuration: 0.25)

        self.bgNode.stop()
        self.chippy.flap(on: false)
        self.logs.children.forEach { $0.removeAllActions() }
        self.removeAction(forKey: "pipes")
        self.run(
            .sequence([
                .run(Sound.hit.play),
                .wait(forDuration: 0.3),
                .run(Sound.die.play),
            ]))
        self.chippy.physicsBody?.isDynamic = false
    }
}

// MARK: - Contact

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.category(is: Body.score) {
            print("Score!!!", contact)
            self.game.score += 1
            self.scoreLabel.text = "\(self.game.score)"
            Sound.impact.impactOccurred()
            Sound.point.play()
        } else if contact.category(is: Body.log) {
            print("Log!!!", contact)

            self.chippy.physicsBody?.velocity = .zero
            self.chippy.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
            self.gameOver()
        } else if contact.category(is: Body.ground) {
            print("Ground!!!", contact)
            self.gameOver()
        }
    }
}

extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.game.playing {
            self.jump()
        } else {
            self.startNewGame()
        }
    }
}

extension SKPhysicsContact {
    func category(is mask: UInt32) -> Bool {
        self.bodyA.categoryBitMask & mask == mask || self.bodyB.categoryBitMask & mask == mask
    }
}
