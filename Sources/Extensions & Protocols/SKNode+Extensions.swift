import SpriteKit

extension SKNode {
    /// Add a child to the given parent only if the child has no parent already.
    ///
    /// - parameter child: The node to add as a child of the receiver.
    func addChildIfOrphaned(_ child: SKNode) {
        if child.parent == nil {
            self.addChild(child)
        }
    }
}
