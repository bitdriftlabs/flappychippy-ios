import Capture
import UIKit
import AVFoundation

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

        return true
    }
}
