import Capture
import Foundation

private let kMaxRetries = 1

struct HTTPError: Error {
    let code: Int
    let detail: String
}

/// Types adopting the `URLConvertible` protocol can be used to safely construct `URL`s.
public protocol URLConvertible {
    func asURL() -> URL
}

extension URLConvertible {
    var baseURL: URL {
        return AppEnvironment.current.baseURL
    }
}

/// A protocol that defines the interface for an API service.
public protocol APIService where Endpoint: URLConvertible {
    associatedtype Endpoint

    /// The URLSession used to send requests. It can be persisted / provided as needed.
    var session: URLSession { get }
}

final class TaskDelegateWithProgress: NSObject, URLSessionTaskDelegate {
    let closure: @Sendable (Double) -> Void

    init(closure: @Sendable @escaping (Double) -> Void) {
        self.closure = closure
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        self.closure(Double(totalBytesSent) / Double(totalBytesExpectedToSend))
    }
}

extension APIService {
    /**
     * Sends a POST request with the given parameters encoded as JSON. Returns the decoded object.
     *
     * - parameter endpoint: The destination endpoint for the request
     * - parameter params: The parameters to send as a JSON blob
     */
    func post<T>(_ endpoint: Endpoint, params: Any) async throws -> T where T: Decodable {
        var request = URLRequest(url: endpoint.asURL())
        request.httpMethod = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: params)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let data = try await self.request(request)
        return try JSONDecoder.api.decodeAndLog(T.self, from: data)
    }

    /**
     * Sends a GET request with the given parameters encoded in the URL. Returns the decoded object.
     *
     * - parameter endpoint: The destination endpoint for the request
     * - parameter params: The parameters to be encoded into the URL
     */
    func get<T>(_ endpoint: Endpoint, params: [String: String] = [:]) async throws -> T where T: Decodable {
        var urlParameters = URLComponents(url: endpoint.asURL(), resolvingAgainstBaseURL: false)
        urlParameters?.queryItems =
            params
            .map { (key, value) in URLQueryItem(name: key, value: value) }
            .sorted { $0.name < $1.name }

        let request = URLRequest(url: urlParameters?.url ?? endpoint.asURL())
        let data = try await self.request(request)
        return try JSONDecoder.api.decodeAndLog(T.self, from: data)
    }

    // MARK: - Private

    private func request(_ request: URLRequest, attempt: Int = 0) async throws -> Data {
        do {
            let (data, response) = try await self.session.data(for: request)
            let httpResponse = response as? HTTPURLResponse
            let code = httpResponse?.statusCode ?? 500

            if httpResponse?.isRetryable == true && attempt < kMaxRetries {
                return try await self.request(request, attempt: attempt + 1)
            }

            if code >= 400 || code <= 0 {
                let responseText = String(data: data, encoding: .utf8) ?? "<Unknown response>"
                let error = try? JSONDecoder.api.decode(ResponseStatus.self, from: data)
                Logger.logError("⬅️🔴 \(request.debugURL) Error body: \(responseText)")
                throw HTTPError(code: code, detail: error?.error ?? "Unknown error")
            }

            return data
        } catch {
            Logger.logError("⬅️🔴 \(error)")
            throw error
        }
    }

}

// MARK: - Some Handy extensions

extension URLRequest {
    var debugURL: String {
        let url = (url?.absoluteString ?? "none")
        if url.count <= 120 {
            return url
        }

        return "\(url.dropLast(url.count - 120))(...)"
    }
}

extension HTTPURLResponse {
    fileprivate var isRetryable: Bool {
        return [-1, 0, 429, 500, 502, 503, 504].contains(self.statusCode)
    }
}
