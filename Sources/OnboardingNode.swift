import Capture
import SpriteKit

enum SceneButton: String {
    case code
    case ranking
    case play
}

protocol ButtonTouchReceiver {
    func onTouch(on: ButtonNode)
}

final class OnboardingNode: SKNode {
    // swiftlint:disable force_cast
    private lazy var bgNode = self.childNode(withName: "//background") as! BackgroundNode
    private lazy var rankingPanel = self.childNode(withName: "//ranking-panel") as! RankingNode
    private lazy var scoreBoard = self.childNode(withName: "//score-board") as! ScoreBoardNode
    private lazy var ranking = self.childNode(withName: "//ranking") as! ButtonNode
    private lazy var play = self.childNode(withName: "//play") as! ButtonNode
    private lazy var code = self.childNode(withName: "//code") as! ButtonNode
    private lazy var title = self.childNode(withName: "//title") as! SKSpriteNode
    // swiftlint:enable force_cast

    private var lastKnownRanking: [Score] = []
    private var touchedButton: ButtonNode?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isUserInteractionEnabled = true
        self.position = .zero
        self.scoreBoard.isHidden = true
    }

    /// Shows the UI with the score and game controls.
    ///
    /// - parameter best:  The best score the player scored since install
    /// - parameter score: The current game score
    func showScoresUI(best: Int, score: Int) {
        Logger.logScreenView(screenName: "scores")
        self.ranking.animateIn(in: self)
        self.play.animateIn(in: self)
        self.code.animateIn(in: self)
        self.scoreBoard.animateIn(in: self)

        let ranking = self.lastKnownRanking.firstIndex { $0.score <= best }
        self.scoreBoard.setScores(best: best, score: score, ranking: ranking)
    }

    /// Prefetch ranking array for fast access when presented. This also helps us known what medal the user has.
    func prefetchRanking() {
        if !self.lastKnownRanking.isEmpty {
            return
        }

        self.rankingPanel.fetchRanking(initial: self.lastKnownRanking) {
            self.lastKnownRanking = $0
        }
    }

    // MARK: - Private methods

    private func hideUI() {
        self.ranking.animateOut()
        self.play.animateOut()
        self.code.animateOut()
        self.title.animateOut()
        self.scoreBoard.animateOut()
    }

    private func openRepository() {
        Logger.logScreenView(screenName: "github")
        UIApplication.shared.open(kFlappyChippyURL, options: [:], completionHandler: nil)
    }

    private func showRanking() {
        Logger.logScreenView(screenName: "ranking")
        self.rankingPanel.animateIn(in: self, duration: 0.2)
        self.rankingPanel.fetchRanking(initial: self.lastKnownRanking) {
            self.lastKnownRanking = $0
        }
    }
}

// MARK: - Touches

extension OnboardingNode: ButtonTouchReceiver {
    func onTouch(on button: ButtonNode) {
        let sceneButton = button.name.flatMap { SceneButton(rawValue: $0) }
        switch sceneButton {
        case .some(.play): self.hideUI()
        case .some(.code): self.openRepository()
        case .some(.ranking): self.showRanking()
        case .none: break
        }
    }
}
