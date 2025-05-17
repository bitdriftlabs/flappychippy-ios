import Foundation

extension URL {
    /// Initializes a new instance of the receiver using provided static string. The caller
    /// is responsible for ensuring that provided string is a valid URL.
    ///
    /// - parameter staticString: A string representing a URL. The initializer crashes if the string
    ///                           is not a valid URL.
    init(staticString: StaticString) {
        // swiftlint:disable:next force_unwrapping
        self.init(string: String(describing: staticString))!
    }
}
