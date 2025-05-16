import SpriteKit

final class ScoreBoardNode: SKNode {
    private lazy var bestLabel = self.childNode(withName: "best") as! SKLabelNode
    private lazy var bestLabelShadow = self.childNode(withName: "best-shadow") as! SKLabelNode
    private lazy var scoreLabel = self.childNode(withName: "score") as! SKLabelNode
    private lazy var scoreLabelShadow = self.childNode(withName: "score-shadow") as! SKLabelNode
    private lazy var medal = self.childNode(withName: "medal") as! SKSpriteNode

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.zPosition = LayerPriority.panels
    }

    func setScores(best: Int, score: Int) {
        self.bestLabel.text = "\(best)"
        self.bestLabelShadow.text = "\(best)"
        self.scoreLabel.text = "\(score)"
        self.scoreLabelShadow.text = "\(score)"
    }
}
