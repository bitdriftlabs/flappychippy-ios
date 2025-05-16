import GameplayKit
import SpriteKit

enum SceneButton: String {
    case code, ranking, play
}

protocol ButtonTouchReceiver {
    func onTouch(on: ButtonNode)
}

final class OnboardingNode: SKNode {
    private lazy var bgNode = self.childNode(withName: "//background") as! BackgroundNode
    private lazy var rankingPanel = self.childNode(withName: "//ranking-panel") as! RankingNode
    private lazy var scoreBoard = self.childNode(withName: "//score-board") as! ScoreBoardNode
    private lazy var ranking = self.childNode(withName: "//ranking") as! ButtonNode
    private lazy var play = self.childNode(withName: "//play") as! ButtonNode
    private lazy var code = self.childNode(withName: "//code") as! ButtonNode
    private lazy var title = self.childNode(withName: "//title") as! SKSpriteNode

    private var touchedButton: ButtonNode?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isUserInteractionEnabled = true
        self.position = .zero
        self.scoreBoard.removeFromParent()
    }

    func showScoresUI(best: Int, score: Int) {
        self.ranking.animateIn(in: self)
        self.play.animateIn(in: self)
        self.code.animateIn(in: self)
        self.scoreBoard.animateIn(in: self)
        self.scoreBoard.setScores(best: best, score: score)
    }

    private func hideUI() {
        self.ranking.animateOut()
        self.play.animateOut()
        self.code.animateOut()
        self.title.animateOut()
        self.scoreBoard.animateOut()
    }

    private func openRepository() {}

    private func showRanking() {
        self.rankingPanel.animateIn(in: self, duration: 0.2)
        self.rankingPanel.fetchRanking()
    }
}

// MARK: - Touches

extension OnboardingNode: ButtonTouchReceiver {
    func onTouch(on button: ButtonNode) {
        let sceneButton = button.name.flatMap { SceneButton(rawValue: $0) }
        switch sceneButton {
        case .some(.play): self.hideUI()
        case .some(.code): openRepository()
        case .some(.ranking): showRanking()
        case .none: break
        }
    }
}
