import SpriteKit

final class LabelWithShadowNode: SKNode {
    // swiftlint:disable force_cast
    private lazy var scoreLabel = self.childNode(withName: "//score-label") as! SKLabelNode
    private lazy var scoreShadowLabel = self.childNode(withName: "//score-shadow") as! SKLabelNode
    // swiftlint:enable force_cast

    /// The property that holds the text value, setting it will update both the text and the shadow.
    var text: String {
        get { self.scoreLabel.text ?? "" }
        set {
            self.scoreLabel.text = newValue
            self.scoreShadowLabel.text = newValue
        }
    }

    /// Small pop animation that can be used to draw attention to a changing value.
    func pop() {
        let pop = SKAction.sequence([
            .scale(to: 1.2, duration: 0.1),
            .scale(to: 1, duration: 0.1),
        ])
        self.scoreLabel.run(pop)
        self.scoreShadowLabel.run(pop)
    }
}
