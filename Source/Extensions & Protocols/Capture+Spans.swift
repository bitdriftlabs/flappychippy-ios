import Capture
import Foundation

/// All available spans. We don't have any of these name spans
enum GameSpan: String {
    case onboarding = "Onboarding"
    case registration = "Registration"
    case registrationNetwork = "Registration API"
    case game = "Game Span"
    case beforeFirstLog = "Before First Log"
    case jumping = "Jumping between logs"
}

extension Capture.Logger {
    /// A hashmap of the running spans, the maximum size of these map is the number of elements on GameSpan which is very small.
    static var spanMap: [GameSpan: Span] = [:]

    /**
     * Helper function to end a span based on the below span enum.
     *
     * - parameter span:   The span enum to end if found. Fails open if not found.
     * - parameter result: The result of the operation (i.e. failure, canceled, success, unknown)
     */
    static func endSpan(_ span: GameSpan, result: SpanResult) {
        spanMap[span]?.end(result)
        spanMap[span] = nil
    }

    /**
     * Helper function to start a span based on the below span enum.
     *
     * - parameter span:   The span enum to start. It will be tracked on the hashmap. Any existing span will be canceled.
     * - parameter parent: The parent span (by its enum case) to locate in the map and associate to this span.
     * - parameter level:  The verbosity level the span log will be emitted with (eg debug, info, etc)
     */
    static func startSpan(_ span: GameSpan, parent: GameSpan? = nil, level: LogLevel = .debug) {
        if spanMap.keys.contains(span) {
            Self.endSpan(span, result: .canceled)
        }

        let parentID = parent.flatMap { spanMap[$0]?.id }
        spanMap[span] = Self.startSpan(name: span.rawValue, level: level, parentSpanID: parentID)
    }
}
