import SpriteKit

final class ButtonNode: SKSpriteNode {
    private var scale: CGFloat = 1.0
    private let impact = UIImpactFeedbackGenerator()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.scale = self.xScale
    }

    func animateTouchBegan() {
        self.run(SKAction.scale(to: self.scale * 0.7, duration: 0.15))
        self.play(.swoosh)
        impact.impactOccurred()
    }

    func animateTouchEnded() {
        self.run(SKAction.scale(to: self.scale, duration: 0.15))
    }
}
