import SpriteKit

private let kRankingPadding = 20.0

private enum RankingButton: String {
    case back
}

final class RankingNode: SKNode {
    private lazy var background = self.childNode(withName: "//background") as! SKSpriteNode
    private var scale: CGFloat = 1

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.scale = max(self.xScale, self.yScale)

        let ranking: [(name: String, score: Int)] = [
            ("Fz", 1337),
            ("Fz", 1337),
            ("Fz", 1337),
            ("Fz", 1337),
            ("Fz", 1337),
        ]
        self.createTable(ranking: ranking)
    }

    func goBack() {
        self.animateOut()
    }

    private func createTable(ranking: [(name: String, score: Int)]) {
        for (i, (name, score)) in ranking.enumerated() {
            self.createLabel(text: name, aligned: .left, i: i)
            let shadow = self.createLabel(text: name, aligned: .left, i: i)
            shadow.fontColor = .shadow
            shadow.zPosition -= 0.5
            shadow.position.y -= 3

            self.createLabel(text: "\(score)", aligned: .right, i: i)
            let scoreShadow = self.createLabel(text: "\(score)", aligned: .right, i: i)
            scoreShadow.fontColor = .shadow
            scoreShadow.zPosition -= 0.5
            scoreShadow.position.y -= 3
        }
    }

    @discardableResult
    private func createLabel(text: String, aligned: SKLabelHorizontalAlignmentMode, i: Int)
        -> SKLabelNode
    {
        let sign: CGFloat = aligned == .left ? 1 : -1
        let label = SKLabelNode(text: text)
        label.fontName = "Kongtext"
        label.fontColor = .text
        label.fontSize = 20
        label.horizontalAlignmentMode = aligned
        label.position.y = CGFloat(i) * 20
        label.position.x = -(sign * self.background.size.width) / 2 + (sign * kRankingPadding)
        label.zPosition = LayerPriority.text
        self.addChild(label)
        return label
    }

}

// MARK: - Extension Touch Receiver

extension RankingNode: ButtonTouchReceiver {
    func onTouch(on button: ButtonNode) {
        let rankingButton = button.name.flatMap { RankingButton(rawValue: $0) }
        switch rankingButton {
        case .some(.back): goBack()
        case .none: break
        }
    }
}
