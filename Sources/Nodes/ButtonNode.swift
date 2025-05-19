import Capture
import SpriteKit

private let kMinimumTapableDimension = 70.0

final class ButtonNode: SKSpriteNode {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isUserInteractionEnabled = true
        let node = FillerNode(rectOf: CGSize(
            width: max(self.size.width, kMinimumTapableDimension),
            height: max(self.size.height, kMinimumTapableDimension),
        ))
        node.name = "\(self.name ?? "<null>")-tappable-area"
        node.strokeColor = .clear
        self.addChild(node)
    }

    // MARK: - Private methods

    private func animateTouchBegan() {
        self.run(.scale(to: 0.7, duration: 0.15))
        Sound.swoosh.play()
        Sound.impact.impactOccurred()
    }

    private func animateTouchEnded() {
        self.run(.scale(to: 1, duration: 0.15))
    }

    private func animateTouchEnded(_ completion: @escaping () -> Void) {
        self.run(.scale(to: 1, duration: 0.15), completion: completion)
    }
}

// MARK: - Touches

extension ButtonNode {
    override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
        self.animateTouchBegan()
    }

    override func touchesEnded(_: Set<UITouch>, with _: UIEvent?) {
        self.animateTouchEnded()
        var node = self.parent
        Logger.logInfo("Button touched", fields: ["node": self.name])

        while let current = node {
            (current as? ButtonTouchReceiver)?.onTouch(on: self)
            node = current.parent
        }
    }

    override func touchesCancelled(_: Set<UITouch>, with _: UIEvent?) {
        self.animateTouchEnded()
    }
}

// MARK: - Capture Session Replay categorizer

extension ButtonNode: ReplayIdentifiable {
    func identify(frame: CGRect) -> AnnotatedView? {
        AnnotatedView(.button, frame: frame)
    }
}

final class FillerNode: SKShapeNode, ReplayIdentifiable {
    func identify(frame _: CGRect) -> AnnotatedView? {
        return .skipped
    }
}
