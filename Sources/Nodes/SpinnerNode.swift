import SpriteKit

private let kLineCenterDistance = 3.0
private let kLineAlphaInactive = 0.2

private enum LineDirection: CaseIterable {
    case up
    case upRight
    case right
    case downRight
    case down
    case downLeft
    case left
    case upLeft

    var position: CGPoint {
        let size = self.texture.size()
        let delta = (size.height / 2) + kLineCenterDistance

        switch self {
        case .up: return CGPoint(x: 0, y: delta)
        case .upRight: return CGPoint(x: delta, y: delta)
        case .right: return CGPoint(x: delta, y: 0)
        case .downRight: return CGPoint(x: delta, y: -delta)
        case .down: return CGPoint(x: 0, y: -delta)
        case .downLeft: return CGPoint(x: -delta, y: -delta)
        case .left: return CGPoint(x: -delta, y: 0)
        case .upLeft: return CGPoint(x: -delta, y: delta)
        }
    }

    var angle: CGFloat {
        switch self {
        case .up, .upRight, .down, .downLeft: 0
        case .right, .downRight, .left, .upLeft: .pi / 2
        }
    }

    var texture: SKTexture {
        switch self {
        case .up: SpinnerNode.verticalTexture
        case .upRight: SpinnerNode.diagonalTexture
        case .right: SpinnerNode.verticalTexture
        case .downRight: SpinnerNode.diagonalTexture
        case .down: SpinnerNode.verticalTexture
        case .downLeft: SpinnerNode.diagonalTexture
        case .left: SpinnerNode.verticalTexture
        case .upLeft: SpinnerNode.diagonalTexture
        }
    }
}

final class SpinnerNode: SKNode {
    private static let texture = SKTextureAtlas.game.textureNamed("spinner")
    fileprivate static let verticalTexture = SKTextureAtlas.game.textureNamed("spinner-vertical")
    fileprivate static let diagonalTexture = SKTextureAtlas.game.textureNamed("spinner-diagonal")

    private let lines: [SKSpriteNode]

    override init() {
        self.lines = LineDirection.allCases.map { line in
            let node = SKSpriteNode(texture: line.texture)
            node.position = line.position
            node.zPosition = LayerPriority.panels + 1
            node.zRotation = line.angle
            node.alpha = kLineAlphaInactive
            return node
        }

        super.init()
        self.zPosition = LayerPriority.panels + 1
        self.lines.forEach(self.addChild)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func stop() {
        self.removeAllActions()
        self.removeFromParent()
    }

    func spin(in node: SKNode) {
        var i = 0
        node.addChildIfOrphaned(self)

        self.run(
            .repeatForever(
                .sequence([
                    .run {
                        i = (i + 1) % self.lines.count
                        let previousIndex = (i - 1 + self.lines.count) % self.lines.count

                        self.lines[previousIndex].run(
                            .fadeAlpha(to: kLineAlphaInactive, duration: 0.15)
                        )
                        self.lines[i].run(
                            .fadeAlpha(to: 1, duration: 0.15)
                        )
                    },
                    .wait(forDuration: 0.15),
                ])
            )
        )
    }
}
