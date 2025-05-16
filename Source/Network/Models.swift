struct ResponseStatus: Codable {
    let ok: Bool
    let error: String?
}

struct Score: Codable {
    let score: Int
    let name: String
    let email: String

    var short: String {
        let components = self.name.components(separatedBy: " ")
        if (components.first?.count ?? 0) < 10 {
            return components.first ?? ""
        }

        return String(self.name.prefix(8))
    }
}

struct Ranking: Codable {
    let ranking: [Score]
}

struct User: Codable {
    let name: String
    let email: String
    let best: Int
}
