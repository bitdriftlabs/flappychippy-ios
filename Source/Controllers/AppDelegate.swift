import AVFoundation
import Capture
import SpriteKit
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        Logger.initFatalIssueReporting()
        Logger
            .start(
                withAPIKey: kBitdriftAPIKey,
                sessionStrategy: .fixed(),
                apiURL: URL(string: kBitdriftURL)!
            )?
            .enableIntegrations([.urlSession()])

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            Logger.logError("Cannot activate audio session: \(error)")
        }

        SKTextureAtlas.game.preload {}
        DispatchQueue.global(qos: .background).async(execute: Sound.preload)

        return true
    }
}
