import SpriteKit

final class FlashNode: SKShapeNode {
    convenience init(color: UIColor, in node: SKNode) {
        self.init(rect: node.frame)
        self.zPosition = LayerPriority.flash
        self.fillColor = color
        self.alpha = 0.0
        node.addChild(self)
    }

    /// Shows a flash on the screen, happens for example when chippy dies.
    ///
    /// - parameter fadeInDuration:  The time that it takes the flash to fade in into the scene.
    /// - parameter peakAlpha:       This fullscreen node will be animated from alpha=0 to this provided value.
    /// - parameter fadeOutDuration: The time that it takes the flash to fade out from the scene.
    /// - parameter onComplete:      Optional closure that will be called after the flash is shown but before is fading out.
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
