import Foundation

// MARK: - PropsBuilder

/// A result builder for constructing dynamic property dictionaries
@resultBuilder
public enum PropsBuilder {
    /// Builds an empty property dictionary
    public static func buildBlock() -> [String: AnyCodable] {
        [:]
    }

    /// Builds a property dictionary from multiple dictionaries
    public static func buildBlock(_ components: [String: AnyCodable]...) -> [String: AnyCodable] {
        components.merging()
    }

    /// Builds a property dictionary from a single dictionary
    public static func buildExpression(_ expression: [String: AnyCodable]) -> [String: AnyCodable] {
        expression
    }

    /// Builds a property dictionary from an optional dictionary
    public static func buildExpression(_ expression: [String: AnyCodable]?) -> [String: AnyCodable] {
        expression ?? [:]
    }

    /// Builds a property dictionary from an if statement
    public static func buildIf(_ content: [String: AnyCodable]?) -> [String: AnyCodable] {
        content ?? [:]
    }

    /// Builds a property dictionary from the first branch of an if-else statement
    public static func buildEither(first component: [String: AnyCodable]) -> [String: AnyCodable] {
        component
    }

    /// Builds a property dictionary from the second branch of an if-else statement
    public static func buildEither(second component: [String: AnyCodable]) -> [String: AnyCodable] {
        component
    }

    /// Builds a property dictionary from a for loop
    public static func buildArray(_ components: [[String: AnyCodable]]) -> [String: AnyCodable] {
        components.merging()
    }

    /// Builds the final property dictionary
    public static func buildFinalBlock(_ component: [String: AnyCodable]) -> [String: AnyCodable] {
        component
    }
}

// MARK: - Props Convenience Initializer

extension Props {
    /// Initializes props with a result builder for additional properties
    /// - Parameters:
    ///   - card: Card content displayed in RHS sidebar (Markdown-formatted)
    ///   - properties: Result builder for additional properties
    public init(
        card: String? = nil,
        @PropsBuilder properties: () -> [String: AnyCodable]
    ) {
        self.card = card
        let builtProperties = properties()
        self.additionalProperties = builtProperties.isEmpty ? nil : builtProperties
    }
}

// MARK: - Custom Property Convenience Functions

/// Creates a string property
/// - Parameters:
///   - key: The property key
///   - value: The string value
/// - Returns: A dictionary with the single property
public func Property(_ key: String, value: String) -> [String: AnyCodable] {
    [key: .string(value)]
}

/// Creates an integer property
/// - Parameters:
///   - key: The property key
///   - value: The integer value
/// - Returns: A dictionary with the single property
public func Property(_ key: String, value: Int) -> [String: AnyCodable] {
    [key: .int(value)]
}

/// Creates a double property
/// - Parameters:
///   - key: The property key
///   - value: The double value
/// - Returns: A dictionary with the single property
public func Property(_ key: String, value: Double) -> [String: AnyCodable] {
    [key: .double(value)]
}

/// Creates a boolean property
/// - Parameters:
///   - key: The property key
///   - value: The boolean value
/// - Returns: A dictionary with the single property
public func Property(_ key: String, value: Bool) -> [String: AnyCodable] {
    [key: .bool(value)]
}

/// Creates a dictionary property
/// - Parameters:
///   - key: The property key
///   - value: The dictionary value
/// - Returns: A dictionary with the single property
public func Property(_ key: String, value: [String: AnyCodable]) -> [String: AnyCodable] {
    [key: .dictionary(value)]
}

/// Creates an array property
/// - Parameters:
///   - key: The property key
///   - value: The array value
/// - Returns: A dictionary with the single property
public func Property(_ key: String, value: [AnyCodable]) -> [String: AnyCodable] {
    [key: .array(value)]
}

// MARK: - Dictionary Merging Helper

fileprivate func mergeDictionaries(_ dictionaries: [[String: AnyCodable]]) -> [String: AnyCodable] {
    var result: [String: AnyCodable] = [:]
    for dict in dictionaries {
        result.merge(dict) { _, new in new }
    }
    return result
}

// MARK: - Array Merging Helper

extension Array where Element == [String: AnyCodable] {
    /// Merges multiple dictionaries into one
    fileprivate func merging() -> [String: AnyCodable] {
        var result: [String: AnyCodable] = [:]
        for dict in self {
            result.merge(dict) { _, new in new }
        }
        return result
    }
}
