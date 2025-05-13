import SpriteKit

extension SKNode {
    func play(_ sound: Sound) {
        DispatchQueue.main.async {
            self.run(sound.action)
        }
    }
}
