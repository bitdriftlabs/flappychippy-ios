import SpriteKit

final class ScoreBoardNode: SKNode {
    private let medalTextures = [
        SKTextureAtlas.game.textureNamed("medal-gold"),
        SKTextureAtlas.game.textureNamed("medal-silver"),
        SKTextureAtlas.game.textureNamed("medal-copper"),
    ]
    // swiftlint:disable force_cast
    private lazy var bestLabel = self.childNode(withName: "best") as! NumberLabelNode
    private lazy var scoreLabel = self.childNode(withName: "score") as! NumberLabelNode
    private lazy var medal = self.childNode(withName: "medal") as! SKSpriteNode
    // swiftlint:enable force_cast

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.zPosition = LayerPriority.panels - 1
    }

    func setScores(best: Int, score: Int, ranking: Int?) {
        self.bestLabel.value = best
        self.scoreLabel.value = score

        if let ranking, ranking >= 0 && ranking < 3 {
            self.medal.isHidden = false
            self.medal.texture = self.medalTextures[ranking]
        } else {
            self.medal.isHidden = true
        }
    }
}
