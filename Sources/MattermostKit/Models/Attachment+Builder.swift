import Foundation

// MARK: - FieldBuilder

/// A result builder for constructing arrays of `AttachmentField` objects
@resultBuilder
public enum FieldBuilder {
    /// Builds an empty field array
    public static func buildBlock() -> [AttachmentField] {
        []
    }

    /// Builds a field array from multiple field arrays
    public static func buildBlock(_ components: [AttachmentField]...) -> [AttachmentField] {
        components.flatMap { $0 }
    }

    /// Builds a field array from a single field
    public static func buildExpression(_ expression: AttachmentField) -> [AttachmentField] {
        [expression]
    }

    /// Builds a field array from an optional field
    public static func buildExpression(_ expression: AttachmentField?) -> [AttachmentField] {
        expression.map { [$0] } ?? []
    }

    /// Builds a field array from an if statement
    public static func buildIf(_ content: [AttachmentField]?) -> [AttachmentField] {
        content ?? []
    }

    /// Builds a field array from the first branch of an if-else statement
    public static func buildEither(first component: [AttachmentField]) -> [AttachmentField] {
        component
    }

    /// Builds a field array from the second branch of an if-else statement
    public static func buildEither(second component: [AttachmentField]) -> [AttachmentField] {
        component
    }

    /// Builds a field array from a for loop
    public static func buildArray(_ components: [[AttachmentField]]) -> [AttachmentField] {
        components.flatMap { $0 }
    }

    /// Builds the final field array
    public static func buildFinalBlock(_ component: [AttachmentField]) -> [AttachmentField] {
        component
    }
}

// MARK: - ActionBuilder

/// A result builder for constructing arrays of `Action` objects
@resultBuilder
public enum ActionBuilder {
    /// Builds an empty action array
    public static func buildBlock() -> [Action] {
        []
    }

    /// Builds an action array from multiple action arrays
    public static func buildBlock(_ components: [Action]...) -> [Action] {
        components.flatMap { $0 }
    }

    /// Builds an action array from a single action
    public static func buildExpression(_ expression: Action) -> [Action] {
        [expression]
    }

    /// Builds an action array from an optional action
    public static func buildExpression(_ expression: Action?) -> [Action] {
        expression.map { [$0] } ?? []
    }

    /// Builds an action array from an if statement
    public static func buildIf(_ content: [Action]?) -> [Action] {
        content ?? []
    }

    /// Builds an action array from the first branch of an if-else statement
    public static func buildEither(first component: [Action]) -> [Action] {
        component
    }

    /// Builds an action array from the second branch of an if-else statement
    public static func buildEither(second component: [Action]) -> [Action] {
        component
    }

    /// Builds an action array from a for loop
    public static func buildArray(_ components: [[Action]]) -> [Action] {
        components.flatMap { $0 }
    }

    /// Builds the final action array
    public static func buildFinalBlock(_ component: [Action]) -> [Action] {
        component
    }
}

// MARK: - Attachment Field Convenience

extension AttachmentField {
    /// Convenience initializer with short=true by default
    public init(_ title: String, value: String, short: Bool = true) {
        self.title = title
        self.value = value
        self.short = short
    }
}

// MARK: - Field Convenience Function

/// Creates an attachment field with the specified parameters
/// - Parameters:
///   - title: The field title
///   - value: The field value (Markdown-formatted)
///   - short: Whether the field is short enough to display beside other fields (default: true)
/// - Returns: An attachment field
public func Field(_ title: String, value: String, short: Bool = true) -> AttachmentField {
    AttachmentField(title: title, value: value, short: short)
}

// MARK: - Action Convenience Function

/// Creates a button action with a convenience API
/// - Parameters:
///   - text: The button text
///   - style: The button style ("primary", "danger", or "default")
///   - url: The URL to open when clicked
///   - confirm: Optional confirmation dialog
/// - Returns: A configured Action
public func Button(
    text: String,
    style: String? = nil,
    url: String,
    confirm: Confirmation? = nil
) -> Action {
    Action(
        name: text.lowercased().replacingOccurrences(of: " ", with: "_"),
        text: text,
        type: "button",
        style: style,
        url: url,
        confirm: confirm
    )
}
