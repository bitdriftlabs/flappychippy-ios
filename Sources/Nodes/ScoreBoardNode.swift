import SpriteKit

final class ScoreBoardNode: SKNode {
    private let medalTextures = [
        SKTextureAtlas.game.textureNamed("medal-gold"),
        SKTextureAtlas.game.textureNamed("medal-silver"),
        SKTextureAtlas.game.textureNamed("medal-copper"),
    ]
    // swiftlint:disable force_cast
    private lazy var bestLabel = self.childNode(withName: "best") as! SKLabelNode
    private lazy var bestLabelShadow = self.childNode(withName: "best-shadow") as! SKLabelNode
    private lazy var scoreLabel = self.childNode(withName: "score") as! SKLabelNode
    private lazy var scoreLabelShadow = self.childNode(withName: "score-shadow") as! SKLabelNode
    private lazy var medal = self.childNode(withName: "medal") as! SKSpriteNode
    // swiftlint:enable force_cast

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.zPosition = LayerPriority.panels - 1
    }

    func setScores(best: Int, score: Int, ranking: Int?) {
        self.bestLabel.text = "\(best)"
        self.bestLabelShadow.text = "\(best)"
        self.scoreLabel.text = "\(score)"
        self.scoreLabelShadow.text = "\(score)"

        if let ranking {
            self.medal.isHidden = ranking < 0 || ranking > 2
            self.medal.texture = self.medalTextures[ranking]
        } else {
            self.medal.isHidden = true
        }
    }
}
