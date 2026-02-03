import Testing
import Foundation
@testable import MattermostKit

// MARK: - Message Model Tests

@Test("Encode message with all fields")
func encodeMessageWithAllFields() throws {
    // Arrange
    let message = Message(
        text: "Test message",
        channel: "town-square",
        username: "TestBot",
        iconEmoji: ":robot_face:",
        iconURL: "https://example.com/icon.png",
        attachments: [
            Attachment(
                fallback: "Fallback",
                color: "#FF8000",
                text: "Attachment text"
            )
        ],
        props: Props(card: "Card content"),
        type: "custom_type",
        priority: Priority(priority: .important)
    )

    // Act
    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    let data = try encoder.encode(message)
    let json = String(data: data, encoding: .utf8)!

    // Assert
    #expect(json.contains("\"text\""))
    #expect(json.contains("\"channel\""))
    #expect(json.contains("\"icon_emoji\""))
    #expect(json.contains("\"attachments\""))
    #expect(json.contains("\"props\""))
    #expect(json.contains("\"priority\""))
}

@Test("Decode message from JSON")
func decodeMessageFromJSON() throws {
    // Arrange
    let jsonString = """
    {
        "text": "Test message",
        "channel": "town-square",
        "username": "TestBot",
        "icon_emoji": ":robot_face:",
        "attachments": [
            {
                "fallback": "Fallback",
                "color": "#FF8000",
                "text": "Attachment text"
            }
        ]
    }
    """

    // Act
    let decoder = JSONDecoder()
    let message = try decoder.decode(Message.self, from: jsonString.data(using: .utf8)!)

    // Assert
    #expect(message.text == "Test message")
    #expect(message.channel == "town-square")
    #expect(message.username == "TestBot")
    #expect(message.iconEmoji == ":robot_face:")
    #expect(message.attachments?.count == 1)
}

// MARK: - Attachment Model Tests

@Test("Encode attachment with all fields")
func encodeAttachmentWithAllFields() throws {
    // Arrange
    let attachment = Attachment(
        fallback: "Fallback text",
        color: "#36a64f",
        pretext: "Pretext",
        authorName: "Author",
        authorLink: "https://example.com",
        authorIcon: "https://example.com/icon.png",
        title: "Title",
        titleLink: "https://example.com/title",
        text: "Attachment text",
        fields: [
            AttachmentField(title: "Field1", value: "Value1", short: true)
        ],
        imageURL: "https://example.com/image.png",
        thumbURL: "https://example.com/thumb.png",
        footer: "Footer",
        footerIcon: "https://example.com/footer.png",
        actions: [
            Action(
                name: "action1",
                text: "Click me",
                type: "button",
                style: "primary",
                url: "https://example.com/click"
            )
        ]
    )

    // Act
    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    let data = try encoder.encode(attachment)
    let json = String(data: data, encoding: .utf8)!

    // Assert
    #expect(json.contains("\"fallback\""))
    #expect(json.contains("\"color\""))
    #expect(json.contains("\"author_name\""))
    #expect(json.contains("\"fields\""))
    #expect(json.contains("\"actions\""))
}

// MARK: - Priority Model Tests

@Test("Encode priority with urgent level")
func encodePriorityWithUrgentLevel() throws {
    // Arrange
    let priority = Priority(
        priority: .urgent,
        requestedAck: true,
        persistentNotifications: true
    )

    // Act
    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    let data = try encoder.encode(priority)
    let json = String(data: data, encoding: .utf8)!

    // Assert
    #expect(json.contains("\"priority\":\"urgent\""))
    #expect(json.contains("\"requested_ack\""))
    #expect(json.contains("\"persistent_notifications\""))
}

// MARK: - Props Model Tests

@Test("Encode props with card")
func encodePropsWithCard() throws {
    // Arrange
    let props = Props(card: "Card content for sidebar")

    // Act
    let encoder = JSONEncoder()
    let data = try encoder.encode(props)
    let json = String(data: data, encoding: .utf8)!

    // Assert
    #expect(json.contains("\"card\""))
    #expect(json.contains("Card content for sidebar"))
}
