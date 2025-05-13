import SpriteKit

private let kImageScaleFactor: CGFloat = 1.5
private let kDurationPerPixel: CGFloat = 0.006

final class BackgroundNode: SKSpriteNode {
    private let backgroundTexture = textures.textureNamed("bg")
    private let bottomTexture = textures.textureNamed("bg-bottom")

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.zPosition = zIndex.background
    }

    func loop(named: String, n: Int = 2, texture: SKTexture, speed: CGFloat, y: CGFloat) {
        let width = texture.size().width * kImageScaleFactor
        let moveLeft = SKAction.moveBy(x: -width, y: 0, duration: speed * width)
        let reset = SKAction.moveBy(x: width, y: 0, duration: 0.0)
        let loopBackground = SKAction.repeatForever(SKAction.sequence([moveLeft, reset]))
        for i in 0..<2 {
            let node = SKSpriteNode(texture: texture)
            node.xScale = kImageScaleFactor
            node.yScale = kImageScaleFactor
            let size = node.size
            node.position = CGPoint(x: CGFloat(i) * (size.width - 1), y: y)
            node.name = "\(named)-\(i)"
            node.run(loopBackground)
            node.zPosition = zIndex.background + CGFloat(self.children.count)
            self.addChild(node)
        }
    }

    func loop() {
        guard let sceneSize = scene?.size else {
            return
        }

        let bgHeight = backgroundTexture.size().height * kImageScaleFactor
        let bgBottomHeight = bottomTexture.size().height * kImageScaleFactor
        let bgY = (sceneSize.height / 2.0) - (bgHeight / 2.0)
        let bgBottomY = bgY - (bgHeight / 2.0) + (bgBottomHeight / 2.0)
        loop(named: "bg", texture: backgroundTexture, speed: kDurationPerPixel, y: bgY)
        loop(named: "bg-bottom", texture: bottomTexture, speed: kDurationPerPixel / 2, y: bgBottomY)
    }
}
