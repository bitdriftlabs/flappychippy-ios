import Capture
import Foundation

extension JSONEncoder {
    /// Standardize encoder that applies the strategy used by our API server.
    static var api: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
}

extension JSONDecoder {
    /**
     * Decode JSON using JSONDecoder() and additionally log any error that might have happened during decoder.
     *
     * - parameter type: The type of the value to decode.
     * - parameter data: The data to decode from.
     * - returns: A value of the requested type.
     * - throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted, or if the given data is not valid JSON.
     * - throws: An error if any value throws an error during decoding.
     */
    func decodeAndLog<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        do {
            return try self.decode(type, from: data)
        } catch {
            Logger.logError("Error decoding type \(type): \(error)", fields: ["data": data])
            throw error
        }
    }

    /// Standardize decoder that applies the strategy used by our API server.
    static let api = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}
