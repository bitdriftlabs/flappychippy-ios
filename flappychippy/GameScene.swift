import GameplayKit
import SpriteKit

let textures = {
    let atlas = SKTextureAtlas(named: "textures")
    atlas.preload {}
    return atlas
}()

enum Button: String {
    case code, settings, play
}

struct zIndex {
    static let background: CGFloat = -30
    //    static let pipe: CGFloat = -2
    static let chippy: CGFloat = -10
    //    static let land: CGFloat = 0
    //    static let score: CGFloat = 1
    //    static let result: CGFloat = 2
    //    static let resultText: CGFloat = 3
}

final class GameScene: SKScene {
    private lazy var backgroundNode = self.childNode(withName: "//background") as? BackgroundNode
    private lazy var chippy = self.childNode(withName: "//chippy") as? ChippyNode
    private var touchedButton: ButtonNode?

    override func didMove(to view: SKView) {
        self.backgroundNode?.loop()
        self.chippy?.float()
    }

    private func startNewGame() {
        flash(color: .black, fadeInDuration: 0.25, peakAlpha: 1.0, fadeOutDuration: 0.25)
    }

    private func openRepository() {
    }

    private func showSettings() {
    }

    func flash(
        color: UIColor, fadeInDuration: TimeInterval, peakAlpha: CGFloat,
        fadeOutDuration: TimeInterval
    ) {
        let flash = SKShapeNode(
            rect: CGRect(
                x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))
        flash.zPosition = 7
        flash.fillColor = color
        flash.alpha = 0.0
        self.addChild(flash)

        flash.run(
            SKAction.sequence([
                SKAction.fadeAlpha(to: peakAlpha, duration: fadeInDuration),
                SKAction.fadeAlpha(to: 0.0, duration: fadeOutDuration),
                SKAction.removeFromParent(),
            ])
        )
    }
}

// MARK: - Touches

extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchedButton?.animateTouchEnded()
        self.touchedButton = button(for: touches)
        self.touchedButton?.animateTouchBegan()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchedButton?.animateTouchEnded()

        let button = self.touchedButton?.name.flatMap { Button(rawValue: $0) }
        switch button {
        case .some(.play): startNewGame()
        case .some(.code): openRepository()
        case .some(.settings): showSettings()
        case .none: break
        }

        self.touchedButton = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesEnded(touches, with: event)
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
