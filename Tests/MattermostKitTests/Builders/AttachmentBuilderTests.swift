import XCTest
@testable import MattermostKit

/// Tests for the result builder functionality
final class AttachmentBuilderTests: XCTestCase {
    // MARK: - Attachment Builder Tests

    func testEmptyAttachmentBuilder() {
        let message = Message {}
        XCTAssertNil(message.attachments)
    }

    func testSingleAttachmentBuilder() {
        let message = Message {
            Attachment(title: "Test")
        }
        XCTAssertEqual(message.attachments?.count, 1)
        XCTAssertEqual(message.attachments?.first?.title, "Test")
    }

    func testMultipleAttachmentBuilder() {
        let message = Message {
            Attachment(title: "First")
            Attachment(title: "Second")
            Attachment(title: "Third")
        }
        XCTAssertEqual(message.attachments?.count, 3)
        XCTAssertEqual(message.attachments?[0].title, "First")
        XCTAssertEqual(message.attachments?[1].title, "Second")
        XCTAssertEqual(message.attachments?[2].title, "Third")
    }

    func testConditionalAttachmentBuilder() {
        let include = true
        let message = Message {
            Attachment(title: "Always")
            if include {
                Attachment(title: "Sometimes")
            }
        }
        XCTAssertEqual(message.attachments?.count, 2)
    }

    func testConditionalAttachmentBuilderFalse() {
        let include = false
        let message = Message {
            Attachment(title: "Always")
            if include {
                Attachment(title: "Sometimes")
            }
        }
        XCTAssertEqual(message.attachments?.count, 1)
        XCTAssertEqual(message.attachments?.first?.title, "Always")
    }

    func testIfElseAttachmentBuilder() {
        let isSuccess = true
        let message = Message {
            if isSuccess {
                Attachment(title: "Success")
            } else {
                Attachment(title: "Failure")
            }
        }
        XCTAssertEqual(message.attachments?.count, 1)
        XCTAssertEqual(message.attachments?.first?.title, "Success")
    }

    // MARK: - Field Builder Tests

    func testEmptyFieldBuilder() {
        let message = Message {
            Attachment(title: "Test") {}
        }
        XCTAssertNil(message.attachments?.first?.fields)
    }

    func testFieldBuilder() {
        let message = Message {
            Attachment(title: "Test") {
                Field("Branch", value: "main")
                Field("Commit", value: "abc123")
            }
        }
        XCTAssertEqual(message.attachments?.first?.fields?.count, 2)
        XCTAssertEqual(message.attachments?.first?.fields?[0].title, "Branch")
        XCTAssertEqual(message.attachments?.first?.fields?[0].value, "main")
    }

    func testFieldBuilderWithShort() {
        let message = Message {
            Attachment(title: "Test") {
                Field("Branch", value: "main", short: true)
                Field("Description", value: "A long description", short: false)
            }
        }
        XCTAssertEqual(message.attachments?.first?.fields?.count, 2)
        XCTAssertEqual(message.attachments?.first?.fields?[0].short, true)
        XCTAssertEqual(message.attachments?.first?.fields?[1].short, false)
    }

    func testConditionalFieldBuilder() {
        let showDetails = true
        let message = Message {
            Attachment(title: "Test") {
                Field("Title", value: "Value")
                if showDetails {
                    Field("Details", value: "More info")
                }
            }
        }
        XCTAssertEqual(message.attachments?.first?.fields?.count, 2)
    }

    // MARK: - Action Builder Tests

    func testEmptyActionBuilder() {
        let message = Message {
            Attachment.actions {}
        }
        XCTAssertNil(message.attachments?.first?.actions)
    }

    func testActionBuilder() {
        let message = Message {
            Attachment.actions {
                Button(text: "Approve", style: "primary", url: "https://example.com/approve")
                Button(text: "Reject", style: "danger", url: "https://example.com/reject")
            }
        }
        XCTAssertEqual(message.attachments?.count, 1)
        XCTAssertEqual(message.attachments?.first?.actions?.count, 2)
    }

    // MARK: - Combined Tests

    func testMessageWithAllProperties() {
        let message = Message(
            text: "Deployment complete!",
            username: "DeployBot",
            iconEmoji: ":rocket:"
        ) {
            Attachment(color: "#36a64f", title: "Build #123") {
                Field("Branch", value: "main")
                Field("Commit", value: "abc123")
            }
        }

        XCTAssertEqual(message.username, "DeployBot")
        XCTAssertEqual(message.iconEmoji, ":rocket:")
        XCTAssertEqual(message.text, "Deployment complete!")
        XCTAssertEqual(message.attachments?.count, 1)
        XCTAssertEqual(message.attachments?.first?.color, "#36a64f")
        XCTAssertEqual(message.attachments?.first?.title, "Build #123")
        XCTAssertEqual(message.attachments?.first?.fields?.count, 2)
    }

    func testComplexMessage() {
        let hasWarnings = true
        let hasErrors = false

        let message = Message(username: "CIBot", iconEmoji: ":robot_face:") {
            Attachment(color: "#36a64f", title: "Build Summary") {
                Field("Status", value: "Success")
                Field("Duration", value: "5m 32s")
            }

            if hasWarnings {
                Attachment(color: "#ffaa00", title: "Warnings") {
                    Field("Count", value: "3")
                }
            }

            if hasErrors {
                Attachment(color: "#ff0000", title: "Errors") {
                    Field("Count", value: "1")
                }
            }
        }

        XCTAssertEqual(message.attachments?.count, 2)
        XCTAssertEqual(message.attachments?[0].title, "Build Summary")
        XCTAssertEqual(message.attachments?[1].title, "Warnings")
    }

    // MARK: - Codable Tests

    func testResultBuilderEncoding() throws {
        let message = Message(username: "TestBot") {
            Attachment(color: "#36a64f", title: "Test") {
                Field("Key", value: "Value")
            }
        }

        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(message)
        let jsonString = String(data: jsonData, encoding: .utf8)

        XCTAssertNotNil(jsonString)
        XCTAssertTrue(jsonString!.contains("TestBot"))
        XCTAssertTrue(jsonString!.contains("Test"))
        XCTAssertTrue(jsonString!.contains("Key"))
        XCTAssertTrue(jsonString!.contains("Value"))
    }

    func testResultBuilderDecoding() throws {
        let jsonString = """
        {
            "username": "TestBot",
            "attachments": [
                {
                    "title": "Test",
                    "fields": [
                        {"title": "Key", "value": "Value"}
                    ]
                }
            ]
        }
        """

        let decoder = JSONDecoder()
        let message = try decoder.decode(Message.self, from: jsonString.data(using: .utf8)!)

        XCTAssertEqual(message.username, "TestBot")
        XCTAssertEqual(message.attachments?.count, 1)
        XCTAssertEqual(message.attachments?.first?.title, "Test")
        XCTAssertEqual(message.attachments?.first?.fields?.count, 1)
    }

    // MARK: - AttachmentField Convenience Initializer Tests

    func testFieldConvenienceInitializer() {
        let field1 = Field("Title", value: "Value")
        XCTAssertEqual(field1.title, "Title")
        XCTAssertEqual(field1.value, "Value")
        XCTAssertEqual(field1.short, true)  // Default is true

        let field2 = Field("Title", value: "Value", short: false)
        XCTAssertEqual(field2.short, false)
    }

    func testFieldStaticFactory() {
        let field = Field("Title", value: "Value", short: true)
        XCTAssertEqual(field.title, "Title")
        XCTAssertEqual(field.value, "Value")
        XCTAssertEqual(field.short, true)
    }

    // MARK: - Action Convenience Tests

    func testButtonConvenience() {
        let button = Button(text: "Approve", style: "primary", url: "https://example.com/approve")
        XCTAssertEqual(button.text, "Approve")
        XCTAssertEqual(button.style, "primary")
        XCTAssertEqual(button.url, "https://example.com/approve")
        XCTAssertEqual(button.type, "button")
        XCTAssertEqual(button.name, "approve")  // Lowercased, spaces replaced with underscores
    }

    func testButtonConvenienceWithoutStyle() {
        let button = Button(text: "Click Me", url: "https://example.com")
        XCTAssertEqual(button.text, "Click Me")
        XCTAssertNil(button.style)
        XCTAssertEqual(button.name, "click_me")
    }
}
