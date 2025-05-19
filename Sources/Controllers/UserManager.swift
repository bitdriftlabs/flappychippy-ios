import Capture
import Foundation

struct PlayerManager {
    private let api = API()

    /// UserManager singleton for simplicity
    static var shared: Self = .init()

    /// Helper shortcut to return whether the user signed up or not.
    var loggedIn: Bool { self.player.registered }

    /// Returns the current logged in user if any
    var player = Self.load() {
        didSet {
            let data = try? JSONEncoder().encode(self.player)
            UserDefaults.standard.set(data, forKey: "player")
            Logger.addField(withKey: "user_id", value: self.player.playerID)
        }
    }

    /// Sends the user registration to the server, this call silently fails, but luckly we can see failures in
    /// Capture's default network
    /// instrumentation.
    ///
    /// - parameter name:  The name of the player, used in the ranking.
    /// - parameter email: The email of the player.
    mutating func register(name: String, email: String) async -> Bool {
        let result = try? await self.api.register(email: email, name: name)
        self.player = Player(name: name, email: email, best: self.player.best,
                             registered: result == true)
        return result == true
    }

    ///
    /// Update best's player score and store in defaults.
    ///
    /// - parameter best: The new best score the player got.
    mutating func update(best: Int) {
        self.player = Player(
            name: self.player.name,
            email: self.player.email,
            best: best,
            registered: self.player.registered
        )
    }

    // MARK: - Private methods

    private static func load() -> Player {
        let best = UserDefaults.standard.integer(forKey: "best")
        guard
            let data = UserDefaults.standard.data(forKey: "player"),
            let player = try? JSONDecoder().decode(Player.self, from: data)
        else {
            return Player(name: "", email: "", best: best, registered: false)
        }

        return player
    }
}
