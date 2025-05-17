import Capture
import SpriteKit

final class ChippyNode: SKSpriteNode {
    private let animationTextures = [
        SKTextureAtlas.game.textureNamed("flappychippy-frame-1"),
        SKTextureAtlas.game.textureNamed("flappychippy-frame-2"),
        SKTextureAtlas.game.textureNamed("flappychippy-frame-3"),
        SKTextureAtlas.game.textureNamed("flappychippy-frame-2"),
    ]

    private let floatAction = SKAction.sequence([
        SKAction.moveBy(x: 0, y: 35, duration: 1.0),
        SKAction.moveBy(x: 0, y: -35, duration: 1.0),
    ])

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.speed = 1
        self.zPosition = LayerPriority.chippy
        self.setupPhysicsBody(alive: false, falling: false)
    }

    /// Make chippy start or stop flapping (animates the textures).
    ///
    /// - parameter on: A boolean indicating if the flap will begin (true) or stop (false)
    func flap(on: Bool = true) {
        self.removeAction(forKey: "flap")
        if on {
            let flap = SKAction.animate(with: self.animationTextures, timePerFrame: 0.25)
            self.run(.repeatForever(flap), withKey: "flap")
        }
    }

    /// Make chippy start floating up and down (used for the standby screens).
    ///
    /// - parameter on: A boolean indicating if the floating will begin (true) or stop (false)
    func float(on: Bool = true) {
        self.removeAction(forKey: "float")
        if on {
            self.run(.repeatForever(self.floatAction), withKey: "float")
        }
    }

    /// Makes chippy react to physical elements in the world.
    func live() {
        self.flap(on: true)
        self.speed = 1

        self.setupPhysicsBody(alive: true, falling: false)
    }

    /// Applies a force such that it makes chippy jump up.
    func jump() {
        Logger.logDebug("Chippy is jumping!")
        self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: kJumpImpulseY))
    }

    /// Fall all the way to the ground. Happens after hitting a log.
    func fall() {
        Logger.logDebug("Chippy is falling!")
        self.setupPhysicsBody(alive: true, falling: true)
        self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: kCollisionImpulseY))
    }

    /// Chippy will not react to any physical elements anymore and will stop flapping.
    func die() {
        Logger.logDebug("Chippy died")
        self.setupPhysicsBody(alive: false)
        self.flap(on: false)
    }

    // MARK: - Private methods

    private func setupPhysicsBody(alive: Bool, falling: Bool = false) {
        self.physicsBody = SKPhysicsBody(
            circleOfRadius: self.size.width / 2, center: CGPoint(x: -10, y: 0)
        )
        self.physicsBody?.velocity = .zero
        self.physicsBody?.categoryBitMask = Body.chippy
        self.physicsBody?.collisionBitMask = falling ? Body.ground : Body.ground | Body.log
        self.physicsBody?.contactTestBitMask = Body.ground | Body.log
        self.physicsBody?.isDynamic = alive
    }
}
