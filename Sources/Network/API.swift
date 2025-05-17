import Foundation

/// Contains all API operations, all return objects are decoded using our JSONDecoder.api extension.
struct API: APIService {
    enum Endpoint: String, URLConvertible {
        case ranking = "/ranking"
        case register = "/register"

        func asURL() -> URL { self.baseURL.appendingPathComponent(self.rawValue) }
    }

    var session: URLSession

    /// Registers a new user by its name and email.
    ///
    /// - parameter email: The user email to register, email will be used to notify the player if they win in any contest.
    /// - parameter name:  The name of the player.
    ///
    /// - returns: An object describing the operation and an optional error if the operation failed.
    func register(email: String, name: String) async throws -> Bool {
        let status: ResponseStatus = try await self.post(
            .register, params: ["email": email, "name": name]
        )
        return status.ok
    }

    /// Registers a new user by its name and email.
    ///
    /// - parameter email: The user email to register, email will be used to notify the player if they win in any contest.
    /// - parameter name:  The name of the player.
    ///
    /// - returns: An object describing the operation with an optional error if the operation failed.
    func post(score: Int, name: String, email: String) async throws -> ResponseStatus {
        try await self.post(.ranking, params: ["score": score, "name": name, "email": email])
    }

    /// Gets the ranking of the best 10 scores.
    ///
    /// - returns: The ranking or throws if an error occurs.
    func ranking() async throws -> [Score] {
        try await self.get(.ranking)
    }
}
