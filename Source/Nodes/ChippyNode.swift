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
        self.physicsBody?.categoryBitMask = Body.chippy
        self.physicsBody?.collisionBitMask = Body.ground | Body.log
        self.physicsBody?.contactTestBitMask = Body.ground | Body.log
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
}
