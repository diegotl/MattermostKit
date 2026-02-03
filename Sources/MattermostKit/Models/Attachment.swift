import Foundation

// MARK: - Attachment

/// A Mattermost message attachment (Slack-compatible)
public struct Attachment: Sendable, Codable {
    /// Required plain-text summary of the attachment
    public var fallback: String?

    /// Hex color code for left border
    public var color: String?

    /// Text shown above the attachment
    public var pretext: String?

    /// Author name
    public var authorName: String?

    /// Author link URL
    public var authorLink: String?

    /// Author icon URL
    public var authorIcon: String?

    /// Attachment title
    public var title: String?

    /// Title link URL
    public var titleLink: String?

    /// Attachment text (Markdown-formatted)
    public var text: String?

    /// Attachment fields
    public var fields: [AttachmentField]?

    /// Image URL
    public var imageURL: String?

    /// Thumbnail URL
    public var thumbURL: String?

    /// Footer text
    public var footer: String?

    /// Footer icon URL
    public var footerIcon: String?

    /// Footer timestamp (not yet supported by Mattermost)
    public var footerTimestamp: Int?

    /// Interactive actions (buttons)
    public var actions: [Action]?

    public init(
        fallback: String? = nil,
        color: String? = nil,
        pretext: String? = nil,
        authorName: String? = nil,
        authorLink: String? = nil,
        authorIcon: String? = nil,
        title: String? = nil,
        titleLink: String? = nil,
        text: String? = nil,
        fields: [AttachmentField]? = nil,
        imageURL: String? = nil,
        thumbURL: String? = nil,
        footer: String? = nil,
        footerIcon: String? = nil,
        footerTimestamp: Int? = nil,
        actions: [Action]? = nil
    ) {
        self.fallback = fallback
        self.color = color
        self.pretext = pretext
        self.authorName = authorName
        self.authorLink = authorLink
        self.authorIcon = authorIcon
        self.title = title
        self.titleLink = titleLink
        self.text = text
        self.fields = fields
        self.imageURL = imageURL
        self.thumbURL = thumbURL
        self.footer = footer
        self.footerIcon = footerIcon
        self.footerTimestamp = footerTimestamp
        self.actions = actions
    }

    enum CodingKeys: String, CodingKey {
        case fallback
        case color
        case pretext
        case authorName = "author_name"
        case authorLink = "author_link"
        case authorIcon = "author_icon"
        case title
        case titleLink = "title_link"
        case text
        case fields
        case imageURL = "image_url"
        case thumbURL = "thumb_url"
        case footer
        case footerIcon = "footer_icon"
        case footerTimestamp = "ts"
        case actions
    }
}

// MARK: - AttachmentField

/// An attachment field
public struct AttachmentField: Sendable, Codable {
    /// The field title
    public var title: String

    /// The field value (Markdown-formatted)
    public var value: String

    /// Whether the field is short enough to display beside other fields
    public var short: Bool?

    public init(title: String, value: String, short: Bool? = nil) {
        self.title = title
        self.value = value
        self.short = short
    }
}

// MARK: - Action

/// An interactive action button
public struct Action: Sendable, Codable {
    /// The action name
    public var name: String

    /// The button text
    public var text: String

    /// The action type (e.g., "button")
    public var type: String

    /// The button style: "primary", "danger", or "default"
    public var style: String?

    /// The URL to open when clicked
    public var url: String?

    /// Confirmation dialog
    public var confirm: Confirmation?

    public init(
        name: String,
        text: String,
        type: String = "button",
        style: String? = nil,
        url: String? = nil,
        confirm: Confirmation? = nil
    ) {
        self.name = name
        self.text = text
        self.type = type
        self.style = style
        self.url = url
        self.confirm = confirm
    }
}

// MARK: - Confirmation

/// A confirmation dialog for actions
public struct Confirmation: Sendable, Codable {
    /// Confirmation dialog title
    public var title: String?

    /// Confirmation dialog text
    public var text: String

    /// Confirm button text (defaults to "Confirm")
    public var confirmText: String?

    /// Deny button text (defaults to "Cancel")
    public var denyText: String?

    public init(
        title: String? = nil,
        text: String,
        confirmText: String? = nil,
        denyText: String? = nil
    ) {
        self.title = title
        self.text = text
        self.confirmText = confirmText
        self.denyText = denyText
    }

    enum CodingKeys: String, CodingKey {
        case title
        case text
        case confirmText = "confirm"
        case denyText = "deny"
    }
}
