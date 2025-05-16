import SpriteKit

protocol Animatable: AnyObject {}

extension Animatable where Self: SKNode {
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

    func animateOut(duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        let animation = SKAction.group([
            .scale(to: 0, duration: duration),
            .fadeAlpha(to: 0, duration: duration),
        ])
        animation.timingMode = .easeInEaseOut
        self.run(animation, completion: completion ?? {})
    }
}

extension SKNode: Animatable {}
