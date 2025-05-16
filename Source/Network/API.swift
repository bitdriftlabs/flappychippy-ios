import Foundation

private let kRankingAPIURL = URL(string: "https://chippy.bitdrift.io/api/")!

struct API: APIService {
    enum Endpoint: String, URLConvertible {
        case ranking = "/ranking"
        case register = "/register"

        func asURL() -> URL { self.baseURL.appendingPathComponent(self.rawValue)}
    }

    var session: URLSession

    func register(email: String, name: String) async throws -> ResponseStatus {
        try await self.post(.register, params: ["email": email, "name": name])
    }

    func post(score: Int, name: String, email: String) async throws -> ResponseStatus {
        try await self.post(.ranking, params: ["score": score, "name": name, "email": email])
    }

    func ranking() async throws -> Ranking {
        return Ranking(ranking: [
            Score(score: 10, name: "Martin Conte", email: "martin@bitdrift.io"),
        ])
//        try await self.get(.ranking)
    }
}
