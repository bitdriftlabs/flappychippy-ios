import GameplayKit
import SpriteKit

private enum SceneButton: String {
    case code, ranking, play
}

protocol TouchReceiver {
    func onTouch(on: ButtonNode)
}

final class OnboardingScene: SKScene {
    private lazy var bgNode = self.childNode(withName: "//background") as! BackgroundNode
    private lazy var chippy = self.childNode(withName: "//chippy") as! ChippyNode
    private lazy var rankingPanel = self.childNode(withName: "//ranking-panel") as! RankingNode
    private lazy var ranking = self.childNode(withName: "//ranking") as! ButtonNode
    private lazy var play = self.childNode(withName: "//play") as! ButtonNode
    private lazy var code = self.childNode(withName: "//code") as! ButtonNode
    private lazy var title = self.childNode(withName: "//title") as! GameSpriteNode

    private var touchedButton: ButtonNode?

    override func didMove(to view: SKView) {
        self.bgNode.setupNodes(in: self)
        self.bgNode.loop()
        self.chippy.flap()
        self.chippy.float()
    }

    private func startNewGame() {
        guard let scene = SKScene(fileNamed: "GameScene") else {
            return
        }

        FlashNode(color: .white, in: self)
            .flash(fadeInDuration: 0.1, peakAlpha: 0.9, fadeOutDuration: 0.25) {
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene)
            }
    }

    private func openRepository() {
    }

    private func showRanking() {
        self.rankingPanel.showAnimated(in: self)
    }
}

// MARK: - Touches

extension OnboardingScene: TouchReceiver {
    func onTouch(on button: ButtonNode) {
        let sceneButton = button.name.flatMap { SceneButton(rawValue: $0) }
        switch sceneButton {
        case .some(.play): startNewGame()
        case .some(.code): openRepository()
        case .some(.ranking): showRanking()
        case .none: break
        }
    }
}

extension OnboardingScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchedButton?.animateTouchEnded()
        self.touchedButton = button(for: touches)
        self.touchedButton?.animateTouchBegan()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let button = self.touchedButton else { return }

        button.animateTouchEnded()
        self.touchedButton = nil
        self.firstResponder(for: button)?.onTouch(on: button)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesEnded(touches, with: event)
    }

    private func firstResponder(for buttonNode: ButtonNode) -> TouchReceiver? {
        var touchedNode: SKNode? = buttonNode
        while let node = touchedNode {
            if let receiver = node as? TouchReceiver {
                return receiver
            }

            touchedNode = node.parent
        }

        return self
    }

    private func button(for touches: Set<UITouch>) -> ButtonNode? {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = self.nodes(at: location).first
            if let touchedNode = touchedNode as? ButtonNode {
                return touchedNode
            }
        }

        return nil
    }
}
