import SpriteKit

extension SKPhysicsContact {
    /// Checks if the contact was made to the given mask, it checks both collisoning bodies.
    ///
    /// - parameter mask: What logical 'category' mask to check.
    func category(is mask: UInt32) -> Bool {
        self.bodyA.categoryBitMask & mask == mask || self.bodyB.categoryBitMask & mask == mask
    }
}
