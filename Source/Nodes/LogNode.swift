import SpriteKit

private let topTexture = SKTextureAtlas.game.textureNamed("log-top")
private let bottomTexture = SKTextureAtlas.game.textureNamed("log-bottom")

enum CollisonMasks {
    static let chippy: UInt32 = 0x1 << 0
    static let land: UInt32 = 0x1 << 1
    static let log: UInt32 = 0x1 << 2
    static let score: UInt32 = 0x1 << 3
}

private func setup(sprite: SKSpriteNode, named name: String) -> SKSpriteNode {
    sprite.xScale = 0.5
    sprite.yScale = 0.5
    sprite.name = name
    sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
    sprite.physicsBody?.isDynamic = false
    sprite.physicsBody?.categoryBitMask = CollisonMasks.log
    sprite.physicsBody?.contactTestBitMask = CollisonMasks.chippy
    sprite.zPosition = LayerPriority.log
    return sprite
}

final class LogNode: SKNode {
    let width: CGFloat

    init(gapAt y: CGFloat, gapHeight: CGFloat = kLogsGapHeight) {
        let topLog = setup(sprite: SKSpriteNode(texture: topTexture), named: "top-log")
        let bottomLog = setup(sprite: SKSpriteNode(texture: bottomTexture), named: "bottom-log")

        topLog.position.y = y + (gapHeight / 2) + (topLog.size.height / 2)
        bottomLog.position.y = y - (gapHeight / 2) - (topLog.size.height / 2)

        let gapNode = SKNode()
        gapNode.name = "gap"
        gapNode.position.y = topLog.position.y + (topLog.size.height / 2)
        gapNode.physicsBody = SKPhysicsBody(
            rectangleOf: CGSize(width: topLog.size.width, height: gapHeight)
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
