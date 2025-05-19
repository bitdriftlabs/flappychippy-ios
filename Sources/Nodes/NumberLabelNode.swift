import Capture
import SpriteKit

final class NumberLabelNode: SKNode {
    private static let textures: [SKTexture] = (0..<10).map {
        SKTextureAtlas.game.textureNamed("\($0)")
    }

    var value: Int {
        didSet { self.drawText() }
    }

    init(value: Int) {
        self.value = value
        super.init()
        self.drawText()
    }

    required init?(coder aDecoder: NSCoder) {
        self.value = 0
        super.init(coder: aDecoder)
        self.drawText()
    }

    /// Small pop animation that can be used to draw attention to a changing value.
    func pop() {
        let pop = SKAction.sequence([
            .scale(to: 1.2, duration: 0.1),
            .scale(to: 1, duration: 0.1),
        ])

        self.children.forEach { $0.run(pop) }
    }

    // MARK: - Private methods

    private func drawText() {
        let value = String(self.value)
        let mid = CGFloat(value.count) / 2

        self.children.forEach { $0.removeFromParent() }
        for (i, digit) in String(value).enumerated() {
            let node = SKSpriteNode(texture: Self.textures[digit.wholeNumberValue ?? 0])
            node.position.x = node.size.width * (mid - CGFloat(i) - 0.5)
            self.addChild(node)
        }
    }
}

// MARK: - Capture Session Replay categorizer

extension NumberLabelNode: ReplayIdentifiable {
    func identify(frame: CGRect) -> AnnotatedView? {
        AnnotatedView(.label, frame: frame)
    }
}
