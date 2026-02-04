import Foundation

// MARK: - AttachmentBuilder

/// A result builder for constructing arrays of `Attachment` objects
@resultBuilder
public enum AttachmentBuilder {
    /// Builds an empty attachment array
    public static func buildBlock() -> [Attachment] {
        []
    }

    /// Builds an attachment array from multiple attachment arrays
    public static func buildBlock(_ components: [Attachment]...) -> [Attachment] {
        components.flatMap { $0 }
    }

    /// Builds an attachment array from a single attachment
    public static func buildExpression(_ expression: Attachment) -> [Attachment] {
        [expression]
    }

    /// Builds an attachment array from an optional attachment
    public static func buildExpression(_ expression: Attachment?) -> [Attachment] {
        expression.map { [$0] } ?? []
    }

    /// Builds an attachment array from an array of attachments (pass-through)
    public static func buildExpression(_ expression: [Attachment]) -> [Attachment] {
        expression
    }

    /// Builds an attachment array from an if statement
    public static func buildIf(_ content: [Attachment]?) -> [Attachment] {
        content ?? []
    }

    /// Builds an attachment array from the first branch of an if-else statement
    public static func buildEither(first component: [Attachment]) -> [Attachment] {
        component
    }

    /// Builds an attachment array from the second branch of an if-else statement
    public static func buildEither(second component: [Attachment]) -> [Attachment] {
        component
    }

    /// Builds an attachment array from a for loop
    public static func buildArray(_ components: [[Attachment]]) -> [Attachment] {
        components.flatMap { $0 }
    }

    /// Builds the final attachment array
    public static func buildFinalBlock(_ component: [Attachment]) -> [Attachment] {
        component
    }
}

// MARK: - Message Convenience Initializer

extension Message {
    /// Initializes a message with a result builder for attachments
    /// - Parameters:
    ///   - text: Markdown-formatted message text
    ///   - channel: Override the default channel
    ///   - username: Override the default username
    ///   - iconEmoji: Override with emoji (e.g., ":rocket:")
    ///   - iconURL: Override with image URL
    ///   - props: JSON metadata
    ///   - type: Post type (must begin with "custom_")
    ///   - priority: Message priority
    ///   - attachments: Result builder for attachments
    public init(
        text: String? = nil,
        channel: String? = nil,
        username: String? = nil,
        iconEmoji: String? = nil,
        iconURL: String? = nil,
        props: Props? = nil,
        type: String? = nil,
        priority: Priority? = nil,
        @AttachmentBuilder attachments: () -> [Attachment]
    ) {
        let builtAttachments = attachments()
        self.text = text
        self.channel = channel
        self.username = username
        self.iconEmoji = iconEmoji
        self.iconURL = iconURL
        self.attachments = builtAttachments.isEmpty ? nil : builtAttachments
        self.props = props
        self.type = type
        self.priority = priority
    }
}

// MARK: - Attachment Convenience Initializer

extension Attachment {
    /// Initializes an attachment with a result builder for fields
    /// - Parameters:
    ///   - color: Hex color code for left border
    ///   - title: Attachment title
    ///   - titleLink: Optional title link URL
    ///   - text: Attachment text (Markdown-formatted)
    ///   - fallback: Plain-text summary
    ///   - pretext: Text shown above the attachment
    ///   - authorName: Author name
    ///   - authorLink: Author link URL
    ///   - authorIcon: Author icon URL
    ///   - imageURL: Image URL
    ///   - thumbURL: Thumbnail URL
    ///   - footer: Footer text
    ///   - footerIcon: Footer icon URL
    ///   - builder: A result builder closure that provides the fields
    public init(
        color: String? = nil,
        title: String? = nil,
        titleLink: String? = nil,
        text: String? = nil,
        fallback: String? = nil,
        pretext: String? = nil,
        authorName: String? = nil,
        authorLink: String? = nil,
        authorIcon: String? = nil,
        imageURL: String? = nil,
        thumbURL: String? = nil,
        footer: String? = nil,
        footerIcon: String? = nil,
        @FieldBuilder builder: () -> [AttachmentField]
    ) {
        let builtFields = builder()
        self.fallback = fallback
        self.color = color
        self.pretext = pretext
        self.authorName = authorName
        self.authorLink = authorLink
        self.authorIcon = authorIcon
        self.title = title
        self.titleLink = titleLink
        self.text = text
        self.fields = builtFields.isEmpty ? nil : builtFields
        self.imageURL = imageURL
        self.thumbURL = thumbURL
        self.footer = footer
        self.footerIcon = footerIcon
        self.footerTimestamp = nil
        self.actions = nil
    }
}

// MARK: - Actions Convenience

extension Attachment {
    /// Creates an attachment with actions built via result builder
    public static func actions(@ActionBuilder builder: () -> [Action]) -> Attachment {
        let actions = builder()
        return Attachment(actions: actions.isEmpty ? nil : actions)
    }

    /// Creates an attachment with both fields and actions
    public init(
        @FieldBuilder fieldsBuilder: () -> [AttachmentField],
        @ActionBuilder actionsBuilder: () -> [Action]
    ) {
        let fields = fieldsBuilder()
        let actions = actionsBuilder()
        self.fields = fields.isEmpty ? nil : fields
        self.actions = actions.isEmpty ? nil : actions
        self.fallback = nil
        self.color = nil
        self.pretext = nil
        self.authorName = nil
        self.authorLink = nil
        self.authorIcon = nil
        self.title = nil
        self.titleLink = nil
        self.text = nil
        self.imageURL = nil
        self.thumbURL = nil
        self.footer = nil
        self.footerIcon = nil
        self.footerTimestamp = nil
    }
}
