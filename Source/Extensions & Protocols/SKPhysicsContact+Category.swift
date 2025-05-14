import SpriteKit

extension SKPhysicsContact {
    func category(is mask: UInt32) -> Bool {
        self.bodyA.categoryBitMask & mask == mask || self.bodyB.categoryBitMask & mask == mask
    }
}
