import GameplayKit
import SpriteKit

enum SceneButton: String {
    case code, ranking, play
}

protocol TouchReceiver {
    func onTouch(on: ButtonNode)
}

final class OnboardingNode: SKNode {
    private lazy var bgNode = self.childNode(withName: "//background") as! BackgroundNode
    private lazy var rankingPanel = self.childNode(withName: "//ranking-panel") as! RankingNode
    private lazy var ranking = self.childNode(withName: "//ranking") as! ButtonNode
    private lazy var play = self.childNode(withName: "//play") as! ButtonNode
    private lazy var code = self.childNode(withName: "//code") as! ButtonNode
    private lazy var title = self.childNode(withName: "//title") as! SKSpriteNode

    private var touchedButton: ButtonNode?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isUserInteractionEnabled = true
    }

    func showScoresUI() {
        self.ranking.animateIn(in: self)
        self.play.animateIn(in: self)
        self.code.animateIn(in: self)
    }

    private func hideUI() {
        self.ranking.animateOut()
        self.play.animateOut()
        self.code.animateOut()
        self.title.animateOut()
    }

    private func openRepository() {}

    private func showRanking() {
        self.rankingPanel.showAnimated(in: self)
    }
}

// MARK: - Touches

extension OnboardingNode: TouchReceiver {
    func onTouch(on button: ButtonNode) {
        let sceneButton = button.name.flatMap { SceneButton(rawValue: $0) }
        switch sceneButton {
        case .some(.play): self.hideUI()
        case .some(.code): openRepository()
        case .some(.ranking): showRanking()
        case .some(.play), .none: break
        }
    }
}
