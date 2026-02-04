import Foundation
import Testing
@testable import MattermostKit

// MARK: - MattermostKit Integration Tests

/*
 # MattermostKit Integration Tests

 These are end-to-end tests that send actual messages to Mattermost via Incoming Webhooks.

 ## Prerequisites

 1. **Create a Mattermost Webhook URL**:
    - Go to your Mattermost workspace
    - Navigate to: Integrations → Incoming Webhooks → Add Incoming Webhook
    - Enter a title (e.g., "Integration Tests")
    - Select a channel (a dedicated test channel is recommended)
    - Copy the Webhook URL

 2. **Set Environment Variables**:

    ```bash
    export MATTERMOST_INTEGRATION_TESTS=1
    export MATTERMOST_TEST_WEBHOOK_URL="https://your-mattermost-server.com/hooks/YOUR_WEBHOOK_ID"
    ```

    Or run tests inline:

    ```bash
    MATTERMOST_INTEGRATION_TESTS=1 MATTERMOST_TEST_WEBHOOK_URL="https://your-mattermost-server.com/hooks/YOUR_WEBHOOK_ID" swift test
    ```

 ## Running Tests

 Run all tests (integration tests will be skipped unless env vars are set):
 ```bash
 swift test
 ```

 Run only integration tests:
 ```bash
 MATTERMOST_INTEGRATION_TESTS=1 MATTERMOST_TEST_WEBHOOK_URL="your_url" swift test --filter "MattermostKit Integration Tests"
 ```

 ## What Gets Tested

 - Simple text messages with Markdown formatting
 - Messages with custom username and icons
 - Single and multiple attachments
 - All attachment features (color, title, text, fields, images, footer)
 - Action buttons with different styles
 - Confirmation dialogs
 - Builder API with conditionals and loops
 - Message priority (important/urgent)
 - Props and card content
 - Special characters and emojis

 ## Important Notes

 - Tests are **serialized** (run one at a time) to avoid rate limits
 - Each test includes a 1-second delay between requests
 - Tests send actual messages to your Mattermost workspace
 - A dedicated test channel is recommended

 ## Safety

 - Integration tests are **disabled by default**
 - Tests only run when both environment variables are set
 - All messages include emoji indicators (🧪) for easy identification
 */

@Suite(
    "MattermostKit Integration Tests",
    .serialized,
    .enabled(if: {
        // Only run integration tests when MATTERMOST_INTEGRATION_TESTS environment variable is set
        ProcessInfo.processInfo.environment["MATTERMOST_INTEGRATION_TESTS"] != nil
    }())
)
struct MattermostKitIntegrationTests {

    // MARK: - Test Configuration

    private var webhookURL: URL {
        guard let urlString = ProcessInfo.processInfo.environment["MATTERMOST_TEST_WEBHOOK_URL"],
              let url = URL(string: urlString) else {
            fatalError("MATTERMOST_TEST_WEBHOOK_URL environment variable must be set to a valid URL")
        }
        return url
    }

    private let defaultTimeout: Duration = .seconds(30)

    // MARK: - Helper Methods

    private func createClient() -> MattermostWebhookClient {
        MattermostWebhookClient(webhookURL: webhookURL)
    }

    private func waitFor(_ duration: Duration) async {
        // Add random jitter (0-500ms) to help avoid rate limits
        let jitter = Duration.seconds(Double.random(in: 0...0.5))
        try? await Task.sleep(for: duration + jitter)
    }

    // MARK: - Simple Text Messages

    @Test("Send simple text message")
    func sendSimpleTextMessage() async throws {
        let client = createClient()
        let message = Message(text: "🧪 Integration Test: Simple text message")
        try await client.send(message)

        await waitFor(.seconds(1))
    }

    @Test("Send message with markdown formatting")
    func sendMessageWithMarkdown() async throws {
        let client = createClient()
        let message = Message(text: """
        🧪 Integration Test: **Markdown formatting**

        This is a *bold text* and this is _italic text_.
        This is `code` and this is a ~~strikethrough~~ text.

        * Bullet point 1
        * Bullet point 2
        * Bullet point 3

        1. Numbered item 1
        2. Numbered item 2
        3. Numbered item 3

        A [link](https://mattermost.com) to Mattermost.
        """)
        try await client.send(message)

        await waitFor(.seconds(1))
    }

    @Test("Send message with username and icon")
    func sendMessageWithUsernameAndIcon() async throws {
        let client = createClient()
        let message = Message(
            text: "🧪 Integration Test: Message with custom username and icon",
            username: "MattermostKit Test Bot",
            iconEmoji: ":robot_face:"
        )
        try await client.send(message)

        await waitFor(.seconds(1))
    }

    @Test("Send message with custom icon URL")
    func sendMessageWithIconURL() async throws {
        let client = createClient()
        let message = Message(
            text: "🧪 Integration Test: Message with icon URL",
            username: "MattermostKit",
            iconURL: "https://httpbin.org/image/png"
        )
        try await client.send(message)

        await waitFor(.seconds(1))
    }

    // MARK: - Attachments

    @Test("Send message with single attachment")
    func sendMessageWithSingleAttachment() async throws {
        let client = createClient()
        let message = Message(
            text: "🧪 Integration Test: Single attachment",
            attachments: [
                Attachment(
                    color: "good",
                    title: "Success",
                    text: "Operation completed successfully"
                )
            ]
        )
        try await client.send(message)

        await waitFor(.seconds(1))
    }

    @Test("Send message with attachment with fields")
    func sendMessageWithAttachmentFields() async throws {
        let client = createClient()
        let message = Message(
            text: "🧪 Integration Test: Attachment with fields",
            attachments: [
                Attachment(
                    color: "#439FE0",
                    title: "Build Report",
                    text: "Build #1234 completed successfully",
                    fields: [
                        AttachmentField(title: "Status", value: "Success", short: true),
                        AttachmentField(title: "Duration", value: "5m 32s", short: true),
                        AttachmentField(title: "Branch", value: "main", short: true),
                        AttachmentField(title: "Commit", value: "abc123", short: true)
                    ]
                )
            ]
        )
        try await client.send(message)

        await waitFor(.seconds(1))
    }

    @Test("Send message with attachment with author")
    func sendMessageWithAttachmentAuthor() async throws {
        let client = createClient()
        let message = Message(
            text: "🧪 Integration Test: Attachment with author",
            attachments: [
                Attachment(
                    color: "warning",
                    authorName: "John Doe",
                    authorLink: "https://mattermost.com",
                    authorIcon: "https://httpbin.org/image/png",
                    title: "Pull Request",
                    text: "Please review my changes",
                    fields: [
                        AttachmentField(title: "Repository", value: "mattermost-server", short: true),
                        AttachmentField(title: "Branch", value: "feature/test", short: true)
                    ]
                )
            ]
        )
        try await client.send(message)

        await waitFor(.seconds(1))
    }

    @Test("Send message with attachment with image")
    func sendMessageWithAttachmentImage() async throws {
        let client = createClient()
        let message = Message(
            text: "🧪 Integration Test: Attachment with image",
            attachments: [
                Attachment(
                    title: "Screenshot",
                    text: "Here is the screenshot you requested",
                    imageURL: "https://httpbin.org/image/png"
                )
            ]
        )
        try await client.send(message)

        await waitFor(.seconds(1))
    }

    @Test("Send message with attachment with thumbnail")
    func sendMessageWithAttachmentThumbnail() async throws {
        let client = createClient()
        let message = Message(
            text: "🧪 Integration Test: Attachment with thumbnail",
            attachments: [
                Attachment(
                    title: "Document Preview",
                    text: " quarterly_report.pdf",
                    fields: [
                        AttachmentField(title: "Size", value: "2.5 MB", short: true),
                        AttachmentField(title: "Type", value: "PDF", short: true)
                    ],
                    thumbURL: "https://httpbin.org/image/png"
                )
            ]
        )
        try await client.send(message)

        await waitFor(.seconds(1))
    }

    @Test("Send message with attachment with footer")
    func sendMessageWithAttachmentFooter() async throws {
        let client = createClient()
        let message = Message(
            text: "🧪 Integration Test: Attachment with footer",
            attachments: [
                Attachment(
                    color: "good",
                    title: "Deployment Complete",
                    text: "Production deployment finished successfully",
                    footer: "DeployBot v2.1",
                    footerIcon: "https://httpbin.org/image/png",
                    footerTimestamp: Int(Date().timeIntervalSince1970)
                )
            ]
        )
        try await client.send(message)

        await waitFor(.seconds(1))
    }

    @Test("Send message with multiple attachments")
    func sendMessageWithMultipleAttachments() async throws {
        let client = createClient()
        let message = Message(
            text: "🧪 Integration Test: Multiple attachments",
            attachments: [
                Attachment(
                    color: "good",
                    title: "Success",
                    text: "Operation completed"
                ),
                Attachment(
                    color: "warning",
                    title: "Warning",
                    text: "Minor issues detected"
                ),
                Attachment(
                    color: "#439FE0",
                    title: "Info",
                    text: "Additional information"
                )
            ]
        )
        try await client.send(message)

        await waitFor(.seconds(1))
    }

    // MARK: - Action Buttons

    @Test("Send message with action button")
    func sendMessageWithActionButton() async throws {
        let client = createClient()
        let message = Message(
            text: "🧪 Integration Test: Action button",
            attachments: [
                Attachment(
                    text: "Click the button below to approve:",
                    actions: [
                        Action(
                            name: "approve",
                            text: "Approve",
                            style: "primary",
                            url: "https://mattermost.com"
                        )
                    ]
                )
            ]
        )
        try await client.send(message)

        await waitFor(.seconds(1))
    }

    @Test("Send message with multiple action buttons")
    func sendMessageWithMultipleActionButtons() async throws {
        let client = createClient()
        let message = Message(
            text: "🧪 Integration Test: Multiple action buttons",
            attachments: [
                Attachment(
                    text: "Choose an action:",
                    actions: [
                        Action(name: "approve", text: "Approve", style: "primary", url: "https://mattermost.com"),
                        Action(name: "deny", text: "Deny", style: "danger", url: "https://mattermost.com"),
                        Action(name: "defer", text: "Defer", url: "https://mattermost.com")
                    ]
                )
            ]
        )
        try await client.send(message)

        await waitFor(.seconds(1))
    }

    @Test("Send message with confirmation dialog")
    func sendMessageWithConfirmationDialog() async throws {
        let client = createClient()
        let message = Message(
            text: "🧪 Integration Test: Confirmation dialog",
            attachments: [
                Attachment(
                    text: "Destructive action requires confirmation",
                    actions: [
                        Action(
                            name: "delete",
                            text: "Delete",
                            style: "danger",
                            confirm: Confirmation(
                                title: "Are you sure?",
                                text: "This action cannot be undone.",
                                confirmText: "Delete",
                                denyText: "Cancel"
                            )
                        )
                    ]
                )
            ]
        )
        try await client.send(message)

        await waitFor(.seconds(1))
    }

    // MARK: - Builder API Tests

    @Test("Send message using builder API - basic")
    func sendMessageUsingBuilderBasic() async throws {
        let client = createClient()
        let message = Message(
            text: "🧪 Builder API - Basic",
            attachments: {
                Attachment(
                    color: "good",
                    title: "Builder API Test",
                    text: "This message was created using the result builder API"
                ) {
                    AttachmentField("Clean", value: "Readable")
                    AttachmentField("Type-safe", value: "Expressive")
                }
            }
        )
        try await client.send(message)

        await waitFor(.seconds(1))
    }

    @Test("Send message using builder API - conditional attachments")
    func sendMessageUsingBuilderConditional() async throws {
        let client = createClient()
        let showWarning = true
        let showError = false

        let message = Message(
            text: "🧪 Builder API - Conditional Attachments",
            attachments: {
                Attachment(
                    color: "good",
                    title: "Main Attachment",
                    text: "This always appears"
                )

                if showWarning {
                    Attachment(
                        color: "warning",
                        title: "Warning",
                        text: "This appears because showWarning is true"
                    )
                }

                if showError {
                    Attachment(
                        color: "danger",
                        title: "Error",
                        text: "This won't appear because showError is false"
                    )
                }
            }
        )
        try await client.send(message)

        await waitFor(.seconds(1))
    }

    @Test("Send message using builder API - for loops")
    func sendMessageUsingBuilderLoops() async throws {
        let client = createClient()
        let items = ["Item 1", "Item 2", "Item 3"]

        let message = Message(
            text: "🧪 Builder API - For Loops",
            attachments: {
                for item in items {
                    Attachment(
                        title: item,
                        text: "This is \(item.lowercased())"
                    )
                }
            }
        )
        try await client.send(message)

        await waitFor(.seconds(1))
    }

    @Test("Send message using builder API - complex message")
    func sendMessageUsingBuilderComplex() async throws {
        let client = createClient()
        let features = [
            ("Result Builders", "Swift 5.4+"),
            ("Type Safety", "Compile-time checks"),
            ("Expressive", "Clean and readable")
        ]

        let message = Message(
            text: "🧪 Builder API - Complex Message",
            username: "Builder Bot",
            iconEmoji: ":construction_worker:",
            attachments: {
                Attachment(
                    color: "good",
                    title: "Builder API Features",
                    text: """
                    This message demonstrates the *full power* of the builder API:
                    • Clean syntax
                    • Type-safe
                    • Expressive
                    """
                ) {
                    for (feature, description) in features {
                        AttachmentField(feature, value: description)
                    }
                }
            }
        )
        try await client.send(message)

        await waitFor(.seconds(1))
    }

    @Test("Send message using builder API - with actions")
    func sendMessageUsingBuilderWithActions() async throws {
        let client = createClient()
        let message = Message(
            text: "🧪 Builder API - With Actions",
            username: "Action Bot",
            attachments: {
                Attachment.actions {
                    Action(name: "approve", text: "Approve", style: "primary", url: "https://mattermost.com")
                    Action(name: "deny", text: "Deny", style: "danger", url: "https://mattermost.com")
                }
            }
        )
        try await client.send(message)

        await waitFor(.seconds(1))
    }

    @Test("Send message using builder API - fields and actions")
    func sendMessageUsingBuilderFieldsAndActions() async throws {
        let client = createClient()
        let message = Message(
            text: "🧪 Builder API - Fields and Actions",
            username: "Builder Bot",
            attachments: {
                Attachment(
                    fieldsBuilder: {
                        AttachmentField("Author", value: "John Doe")
                        AttachmentField("Repository", value: "mattermost-server")
                        AttachmentField("Branch", value: "feature/test")
                    },
                    actionsBuilder: {
                        Action(name: "approve", text: "Approve", style: "primary", url: "https://mattermost.com")
                        Action(name: "changes", text: "Request Changes", style: "danger", url: "https://mattermost.com")
                    }
                )
            }
        )
        try await client.send(message)

        await waitFor(.seconds(1))
    }

    // MARK: - Message Priority

    @Test("Send message with important priority")
    func sendMessageWithImportantPriority() async throws {
        let client = createClient()
        let message = Message(
            text: "🧪 Integration Test: Important priority message",
            priority: Priority(
                priority: .important,
                requestedAck: true
            )
        )
        try await client.send(message)

        await waitFor(.seconds(1))
    }

    @Test("Send message with urgent priority")
    func sendMessageWithUrgentPriority() async throws {
        let client = createClient()
        let message = Message(
            text: "🧪 Integration Test: Urgent priority message",
            priority: Priority(
                priority: .urgent,
                requestedAck: true
            )
        )
        try await client.send(message)

        await waitFor(.seconds(1))
    }

    // MARK: - Props and Card

    @Test("Send message with props card")
    func sendMessageWithPropsCard() async throws {
        let client = createClient()
        let message = Message(
            text: "🧪 Integration Test: Message with card content",
            props: Props(card: "**Card Content**\n\nThis appears in the RHS sidebar when you click on the message.")
        )
        try await client.send(message)

        await waitFor(.seconds(1))
    }

    @Test("Send message with props and custom properties")
    func sendMessageWithPropsCustomProperties() async throws {
        let client = createClient()
        let message = Message(
            text: "🧪 Integration Test: Message with custom props",
            props: Props(
                card: "Custom card content",
                properties: {
                    Property("app_id", value: "mattermostkit")
                    Property("version", value: "1.0.0")
                    Property("source", value: "integration_tests")
                }
            )
        )
        try await client.send(message)

        await waitFor(.seconds(1))
    }

    // MARK: - Special Characters and Formatting

    @Test("Send message with emojis")
    func sendMessageWithEmojis() async throws {
        let client = createClient()
        let message = Message(
            text: "🎉👋 Hello! Testing emoji support: :rocket: :fire: :100: :tada:",
            username: "Emoji Bot :sparkles:",
            iconEmoji: ":robot_face:",
            attachments: [
                Attachment(
                    text: "Emojis in attachments work too! :star: :heart: :thumbsup:"
                )
            ]
        )
        try await client.send(message)

        await waitFor(.seconds(1))
    }

    @Test("Send message with special characters")
    func sendMessageWithSpecialCharacters() async throws {
        let client = createClient()
        let message = Message(
            text: """
            🧪 Integration Test: Special Characters

            Testing special characters: & < > \" ' ` ~ * _ { } [ ] ( )
            Unicode support: 你好 世界 🌍 Ñoño café
            """,
            attachments: [
                Attachment(
                    text: "More special characters: @mentions #channels ~groups",
                    fields: [
                        AttachmentField("Symbols", value: "© ® ™ € £ ¥"),
                        AttachmentField("Math", value: "± × ÷ ≠ ≤ ≥")
                    ]
                )
            ]
        )
        try await client.send(message)

        await waitFor(.seconds(1))
    }

    @Test("Send message with code blocks")
    func sendMessageWithCodeBlocks() async throws {
        let client = createClient()
        let message = Message(
            text: """
            🧪 Integration Test: Code Blocks

            Inline code: `print("Hello, World!")`

            ```
            func greet(name: String) {
                print("Hello, \\(name)!")
            }
            ```

            ```bash
            swift run
            ```
            """
        )
        try await client.send(message)

        await waitFor(.seconds(1))
    }

    // MARK: - Complex Messages

    @Test("Send complex deployment notification")
    func sendComplexDeploymentNotification() async throws {
        let client = createClient()
        let message = Message(
            text: "🚀 Deployment Alert",
            username: "DeployBot",
            iconEmoji: ":rocket:",
            attachments: {
                Attachment(
                    color: "good",
                    pretext: "Build #1234",
                    title: "Deployment Complete",
                    text: "Successfully deployed to production",
                    fields: [
                        AttachmentField("Environment", value: "Production"),
                        AttachmentField("Status", value: "Success"),
                        AttachmentField("Duration", value: "5m 32s"),
                        AttachmentField("Deployed by", value: "John Doe")
                    ],
                    footer: "DeployBot v2.1",
                    footerIcon: "https://httpbin.org/image/png",
                    footerTimestamp: Int(Date().timeIntervalSince1970)
                )
            }
        )
        try await client.send(message)

        await waitFor(.seconds(1))
    }

    @Test("Send error alert message")
    func sendErrorAlertMessage() async throws {
        let client = createClient()
        let message = Message(
            text: "Production Alert",
            username: "AlertBot",
            iconEmoji: ":warning:",
            attachments: {
                Attachment(
                    fieldsBuilder: {
                        AttachmentField("Service", value: "payment-api")
                        AttachmentField("Region", value: "us-east-1")
                        AttachmentField("Severity", value: ":rotating_light: Critical")
                        AttachmentField("Time", value: ISO8601DateFormatter().string(from: Date()))
                    },
                    actionsBuilder: {
                        Action(name: "investigate", text: "Investigate", style: "danger", url: "https://mattermost.com")
                        Action(name: "acknowledge", text: "Acknowledge", url: "https://mattermost.com")
                    }
                )
            }
        )
        try await client.send(message)

        await waitFor(.seconds(1))
    }

    @Test("Send feature announcement message")
    func sendFeatureAnnouncementMessage() async throws {
        let client = createClient()
        let message = Message(
            text: "New feature announcement",
            username: "Product Updates",
            iconEmoji: ":mega:",
            attachments: {
                Attachment(
                    fieldsBuilder: {
                        AttachmentField("Version", value: "2.0")
                        AttachmentField("Release Date", value: ISO8601DateFormatter().string(from: Date()))
                    },
                    actionsBuilder: {
                        Action(name: "learn_more", text: "Learn More", style: "primary", url: "https://mattermost.com")
                        Action(name: "watch_demo", text: "Watch Demo", url: "https://mattermost.com")
                    }
                )
            }
        )
        try await client.send(message)

        await waitFor(.seconds(1))
    }

    // MARK: - Empty/Edge Cases

    @Test("Send message with empty text")
    func sendMessageWithEmptyText() async throws {
        let client = createClient()
        let message = Message(
            text: "",
            attachments: [
                Attachment(text: "Text is empty but attachment is present")
            ]
        )
        try await client.send(message)

        await waitFor(.seconds(1))
    }

    @Test("Send message with only text (no attachments)")
    func sendMessageWithOnlyText() async throws {
        let client = createClient()
        let message = Message(text: "This is a simple message with only text, no attachments.")
        try await client.send(message)

        await waitFor(.seconds(1))
    }

    // MARK: - Confirmation Builder

    @Test("Send message using confirmation builder")
    func sendMessageUsingConfirmationBuilder() async throws {
        let client = createClient()
        let message = Message(
            text: "🧪 Confirmation Builder Test",
            attachments: [
                Attachment(
                    text: "This button uses the confirmation builder",
                    actions: [
                        Action(
                            name: "delete",
                            text: "Delete",
                            style: "danger",
                            confirm: Confirmation(
                                title: "Confirm Deletion",
                                text: "Are you sure you want to delete this item?"
                            ) {
                                ConfirmButton(text: "Yes, Delete", style: "danger")
                                DenyButton(text: "Cancel")
                            }
                        )
                    ]
                )
            ]
        )
        try await client.send(message)

        await waitFor(.seconds(1))
    }

    // MARK: - Final Summary Test

    @Test("Send integration test summary")
    func sendIntegrationTestSummary() async throws {
        let client = createClient()
        let message = Message(
            text: "Integration Tests Complete",
            username: "MattermostKit Test Runner",
            iconEmoji: ":test_tube:",
            attachments: [
                Attachment(
                    color: "good",
                    title: "All MattermostKit features tested successfully!",
                    text: "The following were tested:",
                    fields: [
                        AttachmentField("Features", value: "Simple text messages"),
                        AttachmentField("Features", value: "Markdown formatting"),
                        AttachmentField("Features", value: "Custom username and icons"),
                        AttachmentField("Features", value: "Single and multiple attachments"),
                        AttachmentField("Features", value: "Attachment fields"),
                        AttachmentField("Features", value: "Attachment author"),
                        AttachmentField("Features", value: "Images and thumbnails"),
                        AttachmentField("Features", value: "Footer and timestamps"),
                        AttachmentField("Features", value: "Action buttons"),
                        AttachmentField("Features", value: "Confirmation dialogs"),
                        AttachmentField("Features", value: "Builder API"),
                        AttachmentField("Features", value: "Message priority"),
                        AttachmentField("Features", value: "Props and card"),
                        AttachmentField("Features", value: "Emojis and Unicode"),
                        AttachmentField("Features", value: "Code blocks"),
                        AttachmentField("Features", value: "Complex messages")
                    ]
                ),
                Attachment(
                    color: "#439FE0",
                    text: "Powered by **Swift 6** • Built with ❤️",
                    footer: "MattermostKit Integration Tests"
                )
            ]
        )
        try await client.send(message)
    }
}
