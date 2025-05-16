import SpriteKit

protocol Animatable: AnyObject {
    var node: SKNode { get }
}

extension Animatable where Self: SKNode {
    var node: SKNode { self }
}

extension Animatable {
    func animateIn(in node: SKNode, duration: TimeInterval = 0.3) {
        self.node.isHidden = false
        self.node.setScale(1)
        self.node.alpha = 1

        node.addChildIfOrphaned(self.node)

//        let animation = SKAction.scale(to: 1, duration: duration)
//        let animation = SKAction.group([
//            .sequence([
//                .scale(to: scale * 1.15, duration: duration),
//                .scale(to: scale, duration: duration / 2.0),
//            ]),
//            .fadeAlpha(to: 1, duration: duration),
//        ])
//        self.node.run(animation)
    }

    func animateOut(duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        let animation = SKAction.group([
            .scale(to: 0, duration: duration),
            .fadeAlpha(to: 0, duration: duration),
        ])
        animation.timingMode = .easeInEaseOut
        self.node.run(animation, completion: completion ?? {})
    }
}

extension SKNode: Animatable {}
