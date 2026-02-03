import Foundation

/// A response from the Mattermost webhook API
public struct MattermostResponse: Codable, Sendable {
    /// Whether the request was successful
    public let ok: Bool

    /// An optional error message (present when ok is false)
    public let error: String?

    public init(ok: Bool, error: String? = nil) {
        self.ok = ok
        self.error = error
    }
}
