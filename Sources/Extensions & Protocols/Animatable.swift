import SpriteKit

/// This protocol adds the ability to animate in and out any SKNode subclass.
protocol Animatable: AnyObject {}

extension Animatable where Self: SKNode {
    /// Animates an SKNode in, this method assumes the node is not being shown at the moment and starts from
    /// scale=0 alpha=0.
    ///
    /// - parameter node:     The parent node where the receiver will be added to.
    /// - parameter duration: The animation total duration (default: 0.3s).
    func animateIn(in node: SKNode, duration: TimeInterval = 0.3) {
        node.addChildIfOrphaned(self)
        self.removeAllActions()
        self.isHidden = false
        self.setScale(0)
        self.alpha = 0

        let animation = SKAction.group([
            .sequence([
                .scale(to: 1.15, duration: duration),
                .scale(to: 1, duration: duration / 2.0),
            ]),
            .fadeAlpha(to: 1, duration: duration),
        ])
        self.run(animation)
    }

    /// Animates an SKNode out, this method assumes the node is shown at the moment.
    ///
    /// - parameter duration:   The animation total duration (default: 0.3s).
    /// - parameter completion: An optional callback that will be called once the animation completes.
    func animateOut(duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        let animation = SKAction.group([
            .scale(to: 0, duration: duration),
            .fadeAlpha(to: 0, duration: duration),
        ])
        animation.timingMode = .easeInEaseOut
        self.run(.sequence([animation, .removeFromParent()]), completion: completion ?? {})
    }
}

extension SKNode: Animatable {}
