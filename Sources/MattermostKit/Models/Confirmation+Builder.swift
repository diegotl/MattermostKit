import Foundation

// MARK: - Confirmation Builder

/// A result builder for constructing confirmation dialog components
@resultBuilder
public enum ConfirmationBuilder {
    /// Builds an empty component array
    public static func buildBlock() -> [ConfirmationComponent] {
        []
    }

    /// Builds a component array from multiple components
    public static func buildBlock(_ components: [ConfirmationComponent]...) -> [ConfirmationComponent] {
        components.flatMap { $0 }
    }

    /// Builds a component array from a single component
    public static func buildExpression(_ expression: ConfirmationComponent) -> [ConfirmationComponent] {
        [expression]
    }

    /// Builds a component array from an optional component
    public static func buildExpression(_ expression: ConfirmationComponent?) -> [ConfirmationComponent] {
        expression.map { [$0] } ?? []
    }

    /// Builds a component array from an if statement
    public static func buildIf(_ content: [ConfirmationComponent]?) -> [ConfirmationComponent] {
        content ?? []
    }

    /// Builds a component array from the first branch of an if-else statement
    public static func buildEither(first component: [ConfirmationComponent]) -> [ConfirmationComponent] {
        component
    }

    /// Builds a component array from the second branch of an if-else statement
    public static func buildEither(second component: [ConfirmationComponent]) -> [ConfirmationComponent] {
        component
    }

    /// Builds a component array from a for loop
    public static func buildArray(_ components: [[ConfirmationComponent]]) -> [ConfirmationComponent] {
        components.flatMap { $0 }
    }
}

// MARK: - Confirmation Components

/// Confirmation dialog components
public enum ConfirmationComponent {
    case confirmButton(text: String, style: String? = nil)
    case denyButton(text: String)
}

// MARK: - Confirmation Convenience Initializer

extension Confirmation {
    /// Initializes a confirmation with a result builder for button configuration
    /// - Parameters:
    ///   - title: Confirmation dialog title
    ///   - text: Confirmation dialog text
    ///   - builder: Result builder for confirmation components
    public init(
        title: String? = nil,
        text: String,
        @ConfirmationBuilder builder: () -> [ConfirmationComponent]
    ) {
        self.title = title
        self.text = text

        var confirmText: String?
        var denyText: String?

        for component in builder() {
            switch component {
            case .confirmButton(let text, _):
                confirmText = text
            case .denyButton(let text):
                denyText = text
            }
        }

        self.confirmText = confirmText
        self.denyText = denyText
    }
}

// MARK: - Confirmation Convenience Functions

/// Creates a confirm button component
/// - Parameters:
///   - text: Button text
///   - style: Optional style hint
/// - Returns: A confirm button component
public func ConfirmButton(text: String, style: String? = nil) -> ConfirmationComponent {
    .confirmButton(text: text, style: style)
}

/// Creates a deny button component
/// - Parameter text: Button text
/// - Returns: A deny button component
public func DenyButton(text: String) -> ConfirmationComponent {
    .denyButton(text: text)
}
