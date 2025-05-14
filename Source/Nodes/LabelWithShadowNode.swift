import SpriteKit

final class LabelWithShadowNode: SKNode {
    private lazy var scoreLabel = self.childNode(withName: "//score-label") as! SKLabelNode
    private lazy var scoreShadowLabel = self.childNode(withName: "//score-shadow") as! SKLabelNode

    var text: String {
        get { self.scoreLabel.text ?? "" }
        set {
            self.scoreLabel.text = newValue
            self.scoreShadowLabel.text = newValue
        }
    }

    func pop() {
        let scale = self.scale ?? self.node.xScale
        self.scale = scale

        let pop = SKAction.sequence([
            .scale(to: scale * 1.2, duration: 0.1),
            .scale(to: scale, duration: 0.1),
        ])
        self.scoreLabel.run(pop)
        self.scoreShadowLabel.run(pop)
    }
}
