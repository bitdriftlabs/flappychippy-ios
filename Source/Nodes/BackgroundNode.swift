import SpriteKit

private let kImageScaleFactor: CGFloat = 1.5
private let kDurationPerPixel: CGFloat = 0.006

final class BackgroundNode: SKNode {
    private static let backgroundTexture = SKTextureAtlas.game.textureNamed("bg")
    private static let groundTexture = SKTextureAtlas.game.textureNamed("ground")
    private let ground: (SKSpriteNode, SKSpriteNode)
    private let background: (SKSpriteNode, SKSpriteNode)

    var groundY: CGFloat { ground.0.position.y }

    required init?(coder aDecoder: NSCoder) {
        self.ground = (
            SKSpriteNode(texture: Self.groundTexture),
            SKSpriteNode(texture: Self.groundTexture)
        )
        self.background = (
            SKSpriteNode(texture: Self.backgroundTexture),
            SKSpriteNode(texture: Self.backgroundTexture)
        )
        super.init(coder: aDecoder)
    }

    func loop() {
        for node in [self.ground.0, self.ground.1] {
            let width = node.size.width
            let moveLeft = SKAction.moveBy(x: -width, y: 0, duration: kDurationPerPixel / 2 * width)
            let reset = SKAction.moveBy(x: width, y: 0, duration: 0.0)
            node.removeAllActions()
            node.run(.repeatForever(.sequence([moveLeft, reset])))
        }

        for node in [self.background.0, self.background.1] {
            let width = node.size.width
            let moveLeft = SKAction.moveBy(x: -width, y: 0, duration: kDurationPerPixel * width)
            let reset = SKAction.moveBy(x: width, y: 0, duration: 0.0)
            node.removeAllActions()
            node.run(.repeatForever(.sequence([moveLeft, reset])))
        }
    }

    func stop() {
        for node in [self.ground.0, self.ground.1, self.background.0, self.background.1] {
            node.removeAllActions()
        }
    }

    func setupNodes(in scene: SKScene) {
        let bgHeight = Self.backgroundTexture.size().height * kImageScaleFactor
        let backgroundY = (scene.size.height / 2.0) - (bgHeight / 2.0)
        let groundHeight = Self.groundTexture.size().height * kImageScaleFactor
        let groundY = backgroundY - (bgHeight / 2.0) + (groundHeight / 2.0)

        for (i, node) in [self.ground.0, self.ground.1].enumerated() {
            node.setScale(kImageScaleFactor)
            node.position = CGPoint(x: CGFloat(i) * (node.size.width - 1), y: groundY)
            node.zPosition = LayerPriority.ground + CGFloat(i)
            node.name = "ground-\(i)"
            node.physicsBody = SKPhysicsBody(rectangleOf: node.size,
                                             center: CGPoint(x: 0, y: -node.size.height / 2))
            node.physicsBody?.isDynamic = false
            node.physicsBody?.categoryBitMask = Body.ground
            self.addChild(node)
        }

        for (i, node) in [self.background.0, self.background.1].enumerated() {
            node.setScale(kImageScaleFactor)
            node.position = CGPoint(x: CGFloat(i) * (node.size.width - 1), y: backgroundY)
            node.zPosition = LayerPriority.background + CGFloat(i)
            node.name = "bg-\(i)"
            self.addChild(node)
        }

        // Solid color that goes under the ground to cover the bottom logs overflow
        let bottomGround = SKShapeNode(
            rect: CGRect(
                x: -scene.size.width / 2, y: -scene.size.height / 2,
                width: scene.size.width, height: scene.size.height - bgHeight
            )
        )
        bottomGround.fillColor = .ground
        bottomGround.strokeColor = .clear
        bottomGround.zPosition = LayerPriority.ground + 1
        self.addChild(bottomGround)
    }
}
