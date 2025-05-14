import SpriteKit

private enum RankingButton: String {
    case back
}

final class RankingNode: SKNode {
    private lazy var back = self.childNode(withName: "back")
    private var scale: CGFloat = 1

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.scale = max(self.xScale, self.yScale)
    }

    func showAnimated(in node: SKNode) {
        self.setScale(0)
        self.isHidden = false
        let animation = SKAction.group([
            SKAction.scale(to: scale, duration: 0.2),
            SKAction.fadeAlpha(to: 1, duration: 0.2)
        ])
        animation.timingMode = .easeInEaseOut

        node.addChildIfOrphaned(self)
        self.run(animation)
    }

    func hideAnimated() {
        let animation = SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 0, duration: 0.15),
                SKAction.fadeAlpha(to: 0, duration: 0.2),
            ]),
            SKAction.removeFromParent()
        ])
        animation.timingMode = .easeInEaseOut
        self.run(animation)
    }

    func goBack() {
        self.hideAnimated()
    }
}

// MARK: - Extension Touch Receiver

extension RankingNode: TouchReceiver {
    func onTouch(on button: ButtonNode) {
        let rankingButton = button.name.flatMap { RankingButton(rawValue: $0) }
        switch rankingButton {
        case .some(.back): goBack()
        case .none: break
        }
    }
}
