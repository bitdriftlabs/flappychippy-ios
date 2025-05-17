/// Status obect that is returning in some non-200 response as well as endpoints without a returned model
struct ResponseStatus: Codable {
    /// Whether the operation succeeded or failed
    let ok: Bool
    /// Details about the status, including the reason why the request failed (if it did) as seen by the serer.
    let details: String
}

/// The score entry in the ranking, includes the score and the name of the player
struct Score: Codable {
    /// The best score of the player
    let score: Int
    /// The name of the player that made the ranking
    let name: String

    var short: String {
        let components = self.name.components(separatedBy: " ")
        if (components.first?.count ?? 0) < 10 {
            return components.first ?? ""
        }

        return String(self.name.prefix(8))
    }
}

/// The logged in user containing the scores, this is usually serialized from userdefaults.
struct User: Codable {
    /// The name of the logged in user
    let name: String
    /// The email of the logged in user
    let email: String
    /// The best scored registered since app install
    let best: Int
}
