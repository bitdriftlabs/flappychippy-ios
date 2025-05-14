import SpriteKit


final class ButtonNode: SKSpriteNode {
    var scale: CGFloat = 1.0

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.scale = self.xScale
    }

    func animateTouchBegan() {
        self.run(.scale(to: self.scale * 0.7, duration: 0.15))
        Sound.swoosh.play()
        Sound.impact.impactOccurred()
    }

    func animateTouchEnded() {
        self.run(.scale(to: self.scale, duration: 0.15))
    }

    func animateTouchEnded(_ completion: @escaping () -> Void) {
        self.run(.scale(to: self.scale, duration: 0.15), completion: completion)
    }
}
