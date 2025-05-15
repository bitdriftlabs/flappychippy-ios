import AVFoundation
import Capture
import SpriteKit

private let kRequireMultiple = Set<Sound>([.wing])

enum Sound: String, CaseIterable {
    case swoosh = "sounds/sfx_swooshing.caf"
    case point = "sounds/sfx_point.caf"
    case hit = "sounds/sfx_hit.caf"
    case die = "sounds/sfx_die.caf"
    case wing = "sounds/sfx_wing.caf"

    private static var soundCache: [String: [AVAudioPlayer]] = [:]
    static let impact = UIImpactFeedbackGenerator()
    static let notification = UINotificationFeedbackGenerator()

    func play() {
        guard let sound = Sound.soundCache[self.rawValue]?.first(where: { !$0.isPlaying }) else {
            return
        }

        DispatchQueue.global(qos: .background).async { sound.play() }
    }

    static func preload() {
        for sound in self.allCases {
            guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: nil) else {
                Logger.logError("Invalid sound file", fields: ["sound": sound.rawValue])
                continue
            }

            do {
                let n = kRequireMultiple.contains(sound) ? 3 : 1
                Self.soundCache[sound.rawValue] = []

                for _ in 0..<n {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    Self.soundCache[sound.rawValue]?.append(player)
                }
            } catch {
                Logger.logError("Failed to preload sound \(sound.rawValue): \(error)")
            }
        }
    }
}
