import SpriteKit

extension SKNode {
    func addChildIfOrphaned(_ child: SKNode) {
        if child.parent == nil {
            self.addChild(child)
        }
    }
}
