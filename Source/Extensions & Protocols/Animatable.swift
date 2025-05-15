import SpriteKit

protocol Animatable: AnyObject {
    var node: SKNode { get }
    var scale: CGFloat? { get set }
}

extension Animatable where Self: SKNode {
    var node: SKNode { self }
}

extension Animatable {
    var scale: CGFloat? {
        get { self.node.userData?["scale"] as? CGFloat }
        set { self.node.userData = newValue != nil ? ["scale": newValue ?? 1] : nil }
    }

    func animateIn(in node: SKNode) {
        let scale = self.scale ?? self.node.xScale
        self.scale = scale
        self.node.isHidden = false
        self.node.setScale(0)
        self.node.alpha = 0

        node.addChildIfOrphaned(self.node)

        let animation = SKAction.group([
            .sequence([
                .scale(to: scale * 1.1, duration: 0.3),
                .scale(to: scale, duration: 0.15),
            ]),
            .fadeAlpha(to: 1, duration: 0.3),
        ])
        self.node.run(animation)
    }

    func animateOut(completion: (() -> Void)? = nil) {
        self.scale = self.scale ?? self.node.xScale
        let animation = SKAction.group([
            .scale(to: 0, duration: 0.3),
            .fadeAlpha(to: 0, duration: 0.3),
        ])
        animation.timingMode = .easeInEaseOut
        self.node.run(animation, completion: completion ?? {})
    }
}

extension SKNode: Animatable {}
