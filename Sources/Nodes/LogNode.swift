import SpriteKit

private let kTopTexture = SKTextureAtlas.game.textureNamed("log-top")
private let kBottomTexture = SKTextureAtlas.game.textureNamed("log-bottom")

/// All phisical element masks the game supports
enum CollisonMasks {
    static let chippy: UInt32 = 0x1 << 0
    static let land: UInt32 = 0x1 << 1
    static let log: UInt32 = 0x1 << 2
    static let score: UInt32 = 0x1 << 3
}

private func setup(sprite: SKSpriteNode, named name: String) -> SKSpriteNode {
    sprite.name = name
    sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
    sprite.physicsBody?.isDynamic = false
    sprite.physicsBody?.categoryBitMask = CollisonMasks.log
    sprite.physicsBody?.contactTestBitMask = CollisonMasks.chippy
    sprite.zPosition = LayerPriority.log
    return sprite
}

final class LogNode: SKNode {
    private let width: CGFloat

    init(gapAt y: CGFloat, gapHeight: CGFloat = kLogsGapHeight) {
        let topLog = setup(sprite: SKSpriteNode(texture: kTopTexture), named: "top-log")
        let bottomLog = setup(sprite: SKSpriteNode(texture: kBottomTexture), named: "bottom-log")

        topLog.position.y = y + (gapHeight / 2) + (topLog.size.height / 2)
        bottomLog.position.y = y - (gapHeight / 2) - (topLog.size.height / 2)

        let gapNode = SKNode()
        gapNode.name = "gap"
        gapNode.position.y = y
        gapNode.physicsBody = SKPhysicsBody(
            rectangleOf: CGSize(width: topLog.size.width / 2, height: gapHeight),
            center: CGPoint(x: topLog.size.width * 0.75, y: 0)
        )
        gapNode.physicsBody?.isDynamic = false
        gapNode.physicsBody?.categoryBitMask = CollisonMasks.score
        gapNode.physicsBody?.contactTestBitMask = CollisonMasks.chippy

        self.width = topLog.size.width
        super.init()

        self.addChild(topLog)
        self.addChild(gapNode)
        self.addChild(bottomLog)
    }

    /// Starts the animation from off-screen right to the off-screen left.
    ///
    /// - parameter node:   The node where the logs will be added to.
    /// - parameter bounds: The size of the screen the logs will move on, to calculate min/max X.
    func runMoveAnimation(in node: SKNode, bounds: CGSize) {
        self.position.x = bounds.width / 2

        let delta = self.position.x + self.width + (bounds.width / 2)
        let sequence = SKAction.sequence([
            SKAction.moveTo(
                x: -self.width - (bounds.width / 2), duration: kLogSecondsPerPixel * delta
            ),
            SKAction.moveTo(x: bounds.width / 2, duration: 0),
            SKAction.removeFromParent(),
        ])

        self.run(sequence)
        node.addChild(self)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
