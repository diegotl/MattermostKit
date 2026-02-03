import Foundation

// MARK: - Message

/// A Mattermost webhook message
public struct Message: Sendable, Codable {
    /// Markdown-formatted message text (required if attachments not set)
    public var text: String?

    /// Overrides the default channel
    public var channel: String?

    /// Overrides the default username
    public var username: String?

    /// Overrides the default profile picture with an emoji (e.g., ":rocket:")
    public var iconEmoji: String?

    /// Overrides the default profile picture with an image URL
    public var iconURL: String?

    /// Message attachments (Slack-compatible)
    public var attachments: [Attachment]?

    /// JSON metadata for storing extra information
    public var props: Props?

    /// Post type for plugins (must begin with "custom_")
    public var type: String?

    /// Message priority
    public var priority: Priority?

    /// Initializes a new message
    /// - Parameters:
    ///   - text: Markdown-formatted message text
    ///   - channel: Override the default channel
    ///   - username: Override the default username
    ///   - iconEmoji: Override with emoji (e.g., ":rocket:")
    ///   - iconURL: Override with image URL
    ///   - attachments: Message attachments
    ///   - props: JSON metadata
    ///   - type: Post type (must begin with "custom_")
    ///   - priority: Message priority
    public init(
        text: String? = nil,
        channel: String? = nil,
        username: String? = nil,
        iconEmoji: String? = nil,
        iconURL: String? = nil,
        attachments: [Attachment]? = nil,
        props: Props? = nil,
        type: String? = nil,
        priority: Priority? = nil
    ) {
        self.text = text
        self.channel = channel
        self.username = username
        self.iconEmoji = iconEmoji
        self.iconURL = iconURL
        self.attachments = attachments
        self.props = props
        self.type = type
        self.priority = priority
    }

    enum CodingKeys: String, CodingKey {
        case text
        case channel
        case username
        case iconEmoji = "icon_emoji"
        case iconURL = "icon_url"
        case attachments
        case props
        case type
        case priority
    }
}
