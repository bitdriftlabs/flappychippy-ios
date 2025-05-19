import AVFoundation
import Capture
import SpriteKit
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?,
    ) -> Bool {
        // Safe and lightweight call to initialize the crash reporting engine
        Logger.initFatalIssueReporting()
        // Full logger initialization
        Logger
            .start(
                withAPIKey: kBitdriftAPIKey,
                sessionStrategy: .activityBased(),
                apiURL: kBitdriftURL,
            )?
            .enableIntegrations([.urlSession()], disableSwizzling: true)

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            Logger.logError("Cannot activate audio session: \(error)")
        }

        // Preload sounds and textures
        SKTextureAtlas.game.preload {}
        DispatchQueue.global(qos: .userInteractive).async(execute: Sound.preload)

        return true
    }
}
