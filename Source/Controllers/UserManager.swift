import Foundation

struct UserManager {
    private let api = API(session: .shared)

    /// UserManager singleton for simplicity
    static var shared: Self = .init()

    /// Helper shortcut to return whether the user signed up or not.
    var loggedIn: Bool { !self.current.email.isEmpty }

    /// Returns the current logged in user if any
    var current = Self.load() {
        didSet {
            UserDefaults.standard.set(self.current.email, forKey: "email")
            UserDefaults.standard.set(self.current.name, forKey: "name")
            UserDefaults.standard.set(self.current.best, forKey: "best")
        }
    }

    /**
     * Sends the user registration to the server, this call silently fails, but luckly we can see failures in Capture's default network
     * instrumentation.
     *
     * - parameter name: The name of the player, used in the ranking.
     * - parameter email: The email of the player.
     */
    mutating func register(name: String, email: String) async {
        let result = try? await self.api.register(email: email, name: name)
        if result == true {
            self.current = User(name: name, email: email, best: 0)
        }
    }

    // MARK: - Private methods

    private static func load() -> User {
        let best = UserDefaults.standard.integer(forKey: "best")
        guard
            let name = UserDefaults.standard.string(forKey: "name"),
            let email = UserDefaults.standard.string(forKey: "email")
        else {
            return User(name: "", email: "", best: best)
        }

        return User(name: name, email: email, best: best)
    }
}
