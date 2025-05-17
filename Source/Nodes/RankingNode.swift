import Capture
import SpriteKit

private let kRankingPadding = 20.0
private let kRowHeight = 30.0
private let kCloseButtonOffset = -21.0

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
        self.zPosition = LayerPriority.panels + 3
        self.background.zPosition = self.zPosition
    }

    func fetchRanking(initial: [Score], completion: @escaping ([Score]) -> Void) {
        self.createTable(ranking: initial)

        Task {
            await MainActor.run { self.spinner.spin(in: self) }
            let ranking = (try? await self.api.ranking()) ?? []
            await MainActor.run {
                self.spinner.stop()
                self.createTable(ranking: ranking)
                completion(ranking)
                Logger.logDebug("Ranking returned", fields: ["count": ranking.count])
            }
        }
    }

    private func goBack() {
        self.animateOut(duration: 0.2)
    }

    private func createTable(ranking: [Score]) {
        if ranking.isEmpty {
            let label = self.createLabel(text: "Nobody here!", aligned: .center, i: 0, count: 0)
            label.position.x = 0
        }

        for (i, row) in ranking.enumerated() {
            self.createLabel(text: row.short, aligned: .left, i: i, count: ranking.count)
            self.createLabel(text: "\(row.score)", aligned: .right, i: i, count: ranking.count)
        }
    }

    @discardableResult
    private func createLabel(
        text: String, aligned: SKLabelHorizontalAlignmentMode, i: Int, shadow: Bool = false,
        count: Int
    )
        -> SKLabelNode
    {
        let xSign: CGFloat
        switch aligned {
        case .left: xSign = 1
        case .right: xSign = -1
        default: xSign = 0
        }

        let label = SKLabelNode(text: text)
        label.fontName = "Kongtext"
        label.fontColor = .text
        label.fontSize = 20
        label.horizontalAlignmentMode = aligned
        label.position.y = kRowHeight * CGFloat((count / 2) - i) + kCloseButtonOffset
        label.position.x = -(xSign * self.background.size.width) / 2 + (xSign * kRankingPadding)
        label.zPosition = self.zPosition + 1
        self.addChild(label)

        if !shadow {
            let scoreShadow = self.createLabel(
                text: text, aligned: aligned, i: i, shadow: true,
                count: count
            )
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
