import SpriteKit

final class ChippyNode: SKSpriteNode {
    private let floatAction = SKAction.sequence([
        SKAction.moveBy(x: 0, y: 35, duration: 1.0),
        SKAction.moveBy(x: 0, y: -35, duration: 1.0),
    ])

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.speed = 1
        self.zPosition = zIndex.chippy
    }

    func float() {
        self.run(.repeatForever(floatAction), withKey: "float")
    }
}
