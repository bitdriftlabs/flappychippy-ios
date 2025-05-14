import SpriteKit

extension SKScene {
    static func present(named name: String, from scene: SKScene) {
        guard let newScene = SKScene(fileNamed: name) else {
            return
        }

        FlashNode(color: .white, in: scene)
            .flash(fadeInDuration: 0.1, peakAlpha: 0.9, fadeOutDuration: 0.25) {
                newScene.scaleMode = .aspectFill
                scene.view?.presentScene(newScene)
            }
    }
}
