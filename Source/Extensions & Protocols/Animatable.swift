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
        set { self.node.userData?["scale"] = newValue }
    }

    func animateIn(in node: SKNode) {
        let scale = self.scale ?? self.node.xScale
        self.scale = scale
        self.node.isHidden = false
        self.node.setScale(0)
        self.node.alpha = 0

        node.addChildIfOrphaned(self.node)
        self.node.run(
            .group([
                .sequence([
                    .scale(to: scale * 1.1, duration: 0.3),
                    .scale(to: scale, duration: 0.15),
                ]),
                .fadeAlpha(to: 1, duration: 0.3),
            ])
        )
    }

    func animateOut() {
        self.scale = self.scale ?? self.node.xScale
        self.node.run(
            .group([
                .scale(to: 0, duration: 0.3),
                .fadeAlpha(to: 0, duration: 0.3),
            ])
        )
    }
}

extension SKNode: Animatable {}
