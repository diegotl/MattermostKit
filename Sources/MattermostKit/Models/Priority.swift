import Foundation

// MARK: - Priority

/// Message priority configuration
public struct Priority: Sendable, Codable {
    /// The priority level
    public enum Level: String, Sendable, Codable {
        /// Important message priority
        case important
        /// Urgent message priority
        case urgent
    }

    /// The priority level
    public var priority: Level

    /// Whether to request acknowledgment (only for important/urgent)
    public var requestedAck: Bool?

    /// Whether to send persistent notifications (only for urgent)
    public var persistentNotifications: Bool?

    public init(
        priority: Level,
        requestedAck: Bool? = nil,
        persistentNotifications: Bool? = nil
    ) {
        self.priority = priority
        self.requestedAck = requestedAck
        self.persistentNotifications = persistentNotifications
    }

    enum CodingKeys: String, CodingKey {
        case priority
        case requestedAck = "requested_ack"
        case persistentNotifications = "persistent_notifications"
    }
}
