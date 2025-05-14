import AVFoundation
import Capture
import SpriteKit

enum Sound: String, CaseIterable {
    case swoosh = "sounds/sfx_swooshing.caf"
    case point = "sounds/sfx_point.wav"
    case hit = "sounds/sfx_hit.caf"
    case die = "sounds/sfx_die.caf"

    private static var soundCache: [String: AVAudioPlayer] = [:]
    static let impact = UIImpactFeedbackGenerator()
    static let notification = UINotificationFeedbackGenerator()

    func play() {
        DispatchQueue.global(qos: .background).async {
            Sound.soundCache[self.rawValue]?.play()
        }
    }

    static func preload() {
        for sound in self.allCases {
            guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: nil) else {
                Logger.logError("Invalid sound file", fields: ["sound": sound.rawValue])
                continue
            }

            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                Self.soundCache[sound.rawValue] = player
            } catch {
                Logger.logError("Failed to preload sound \(sound.rawValue): \(error)")
            }
        }
    }
}
