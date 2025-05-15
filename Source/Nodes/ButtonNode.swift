import SpriteKit


final class ButtonNode: SKSpriteNode {
    var scale: CGFloat = 1.0

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isUserInteractionEnabled = true
        self.scale = self.xScale
    }

    private func animateTouchBegan() {
        self.run(.scale(to: self.scale * 0.7, duration: 0.15))
        Sound.swoosh.play()
        Sound.impact.impactOccurred()
    }

    private func animateTouchEnded() {
        self.run(.scale(to: self.scale, duration: 0.15))
    }

    private func animateTouchEnded(_ completion: @escaping () -> Void) {
        self.run(.scale(to: self.scale, duration: 0.15), completion: completion)
    }
}

extension ButtonNode {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.animateTouchBegan()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.animateTouchEnded()
        var node = self.parent
        while let current = node {
            (current as? ButtonTouchReceiver)?.onTouch(on: self)
            node = current.parent
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.animateTouchEnded()
    }
}
