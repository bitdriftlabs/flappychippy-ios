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

    func flap(on: Bool = true) {
        self.removeAction(forKey: "flap")
        if on {
            let flap = SKAction.animate(with: animationTextures, timePerFrame: 0.25)
            self.run(.repeatForever(flap), withKey: "flap")
        }
    }

    func float(on: Bool = true) {
        self.removeAction(forKey: "float")
        if on {
            self.run(.repeatForever(floatAction), withKey: "float")
        }
    }

    func live() {
        self.flap(on: true)
        self.speed = 1

        self.setupPhysicsBody(alive: true, falling: false)
    }

    func jump() {
        self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: kJumpImpulseY))
    }

    func fall() {
        self.setupPhysicsBody(alive: true, falling: true)
        self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: kCollisionImpulseY))
    }

    func die() {
        self.setupPhysicsBody(alive: false)
        self.flap(on: false)
    }

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
