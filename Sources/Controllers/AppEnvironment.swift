import Foundation

/// The server environment to use according to where the app is running.
public struct AppEnvironment: Sendable {
    /// This baseURL is used on all the routes and changes depending on the selected environment
    public let baseURL: URL

    /// Production environment. Should not be used for testing.
    public static let prod = Self(
        baseURL: URL(staticString: "https://chippy.bitdrift.io/")
    )

    /// The current selected environment is decided based on compiler flags for now. We keep this as a `var` to be able to
    /// switch environments in runtime.
    public static let current = prod
}
