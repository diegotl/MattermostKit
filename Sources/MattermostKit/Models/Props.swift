import Foundation

// MARK: - Props

/// Mattermost post properties for metadata
public struct Props: Sendable, Codable {
    /// Card content displayed in RHS sidebar (Markdown-formatted)
    public var card: String?

    /// Additional custom properties
    public var additionalProperties: [String: AnyCodable]?

    public init(
        card: String? = nil,
        additionalProperties: [String: AnyCodable]? = nil
    ) {
        self.card = card
        self.additionalProperties = additionalProperties
    }

    enum CodingKeys: String, CodingKey {
        case card
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        card = try container.decodeIfPresent(String.self, forKey: .card)

        // Decode additional properties dynamically
        // Note: This is a simplified version - full implementation would need
        // to handle the entire props object as a dictionary
        additionalProperties = nil
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(card, forKey: .card)

        // Encode additional properties if present
        if let additional = additionalProperties {
            let dynamicContainer = container.superEncoder()
            try additional.encode(to: dynamicContainer)
        }
    }
}

// MARK: - AnyCodable

/// A type-erased codable value for dynamic JSON properties
public enum AnyCodable: Sendable, Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case dictionary([String: AnyCodable])
    case array([AnyCodable])
    case null

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .null
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else if let double = try? container.decode(Double.self) {
            self = .double(double)
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let array = try? container.decode([AnyCodable].self) {
            self = .array(array)
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            self = .dictionary(dictionary)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "AnyCodable value cannot be decoded"
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .null:
            try container.encodeNil()
        case .string(let string):
            try container.encode(string)
        case .int(let int):
            try container.encode(int)
        case .double(let double):
            try container.encode(double)
        case .bool(let bool):
            try container.encode(bool)
        case .array(let array):
            try container.encode(array)
        case .dictionary(let dictionary):
            try container.encode(dictionary)
        }
    }
}
