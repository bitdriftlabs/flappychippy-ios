import SpriteKit

private let kRankingPadding = 20.0

private enum RankingButton: String {
    case back
}

final class RankingNode: SKNode {
    private lazy var background = self.childNode(withName: "background") as! SKSpriteNode
    private var scale: CGFloat = 1
    private let spinner = SpinnerNode()
    private let api = API(session: .shared)

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.scale = max(self.xScale, self.yScale)
    }

    func fetchRanking() {
        Task {
            await MainActor.run { self.spinner.spin(in: self) }
            let ranking = try? await self.api.ranking()
            await MainActor.run {
                self.spinner.stop()
                self.createTable(ranking: ranking)
            }
        }
    }

    private func goBack() {
        self.animateOut(duration: 0.2)
    }

    private func createTable(ranking: Ranking?) {
        let list = ranking?.ranking ?? []
        if list.isEmpty {
            let label = self.createLabel(text: "Nobody here!", aligned: .center, i: 0)
            label.position.x = 0
        }

        for (i, row) in list.enumerated() {
            self.createLabel(text: row.short, aligned: .left, i: i)
            self.createLabel(text: "\(row.score)", aligned: .right, i: i)
        }
    }

    @discardableResult
    private func createLabel(
        text: String, aligned: SKLabelHorizontalAlignmentMode, i: Int, shadow: Bool = false
    )
        -> SKLabelNode
    {
        let sign: CGFloat
        switch aligned {
        case .left: sign = 1
        case .right: sign = -1
        default: sign = 0
        }

        let label = SKLabelNode(text: text)
        label.fontName = "Kongtext"
        label.fontColor = .text
        label.fontSize = 20
        label.horizontalAlignmentMode = aligned
        label.position.y = CGFloat(i) * 20
        label.position.x = -(sign * self.background.size.width) / 2 + (sign * kRankingPadding)
        label.zPosition = LayerPriority.text
        self.addChild(label)

        if !shadow {
            let scoreShadow = self.createLabel(text: text, aligned: aligned, i: i, shadow: true)
            scoreShadow.fontColor = .shadow
            scoreShadow.zPosition -= 0.5
            scoreShadow.position.y -= 3
        }

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
