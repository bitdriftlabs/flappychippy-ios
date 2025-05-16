import Foundation

struct UserManager {
    static var shared: Self = .init()
    private let api = API(session: .shared)

    var loggedIn: Bool { self.current != nil }

    var current = Self.load() {
        didSet {
            UserDefaults.standard.set(self.current?.email, forKey: "email")
            UserDefaults.standard.set(self.current?.name, forKey: "name")
            UserDefaults.standard.set(self.current?.best ?? 0, forKey: "best")
        }
    }

    mutating func register(name: String, email: String) async {
        let result = try? await self.api.register(email: email, name: name)
        if result?.ok == true {
            self.current = User(name: name, email: email, best: 0)
        }
    }

    private static func load() -> User? {
        let best = UserDefaults.standard.integer(forKey: "best")
        guard
            let name = UserDefaults.standard.string(forKey: "name"),
            let email = UserDefaults.standard.string(forKey: "email")
        else {
            return nil
        }

        return User(name: name, email: email, best: best)
    }
}
