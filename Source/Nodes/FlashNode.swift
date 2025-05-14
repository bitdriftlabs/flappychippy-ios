import SpriteKit

final class FlashNode: SKShapeNode {
    convenience init(color: UIColor, in node: SKNode) {
        self.init(rect: node.frame)
        self.zPosition = LayerPriority.flash
        self.fillColor = color
        self.alpha = 0.0
        node.addChild(self)
    }

    func flash(
        fadeInDuration: TimeInterval, peakAlpha: CGFloat, fadeOutDuration: TimeInterval,
        onComplete: (() -> Void)? = nil
    ) {
        self.run(
            .sequence([
                .fadeAlpha(to: peakAlpha, duration: fadeInDuration),
                .run { onComplete?() },
                .fadeAlpha(to: 0.0, duration: fadeOutDuration),
                .removeFromParent(),
            ])
        )
    }
}
