# MattermostKit

<p align="center">
    <img src="logo.png" alt="MattermostKit Logo" width="400">
</p>

<p align="center">
    <a href="https://github.com/diegotl/MattermostKit/actions/workflows/ci.yml">
        <img src="https://github.com/diegotl/MattermostKit/actions/workflows/ci.yml/badge.svg" alt="CI">
    </a>
    <a href="https://github.com/diegotl/MattermostKit/releases">
        <img src="https://img.shields.io/github/v/release/diegotl/MattermostKit" alt="Version">
    </a>
    <a href="LICENSE">
        <img src="https://img.shields.io/github/license/diegotl/MattermostKit" alt="License">
    </a>
    <img src="https://img.shields.io/badge/platform-macos%20%7C%20ios%20%7C%20tvos%20%7C%20watchos-lightgrey" alt="Platform">
    <img src="https://img.shields.io/badge/swift-6.0-orange.svg" alt="Swift">
    <img src="https://img.shields.io/badge/dependencies-zero-brightgreen" alt="Dependencies">
</p>

[Swift](https://swift.org) package for sending messages to [Mattermost](https://mattermost.com) via Incoming Webhooks with full support for Slack-compatible attachments and Mattermost-specific features.

## Features

- **Modern Swift API** - Built with Swift 6, async/await, and strict concurrency
- **Type-Safe** - Full Codable support with compile-time safety
- **Attachments** - Slack-compatible attachment support for rich messages
- **Mattermost-Specific** - Support for `props.card` and message priority
- **Flexible** - Send simple text messages or rich formatted messages

## Requirements

- macOS 12.0+
- iOS 15.0+
- tvOS 15.0+
- watchOS 8.0+
- Swift 6.0+

## Installation

### Swift Package Manager

Add MattermostKit to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/diegotl/MattermostKit.git", from: "1.0.0")
]
```

Or add it directly in Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL
3. Select the version rule

## Quick Start

```swift
import MattermostKit

// Create a webhook client
let client = try MattermostWebhookClient.create(
    webhookURLString: "https://mattermost.server.com/hooks/YOUR/WEBHOOK/URL"
)

// Send a simple message
try await client.send(Message(text: "Hello, Mattermost!"))
```

## Usage

### Simple Text Message

```swift
let message = Message(text: "Deployment completed successfully!")
try await client.send(message)
```

### Message with Attachments

```swift
let message = Message(
    username: "DeployBot",
    iconEmoji: ":rocket:",
    text: "Deployment complete!",
    attachments: [
        Attachment(
            color: "#36a64f",
            title: "Build #123",
            text: "Succeeded in 5m 32s",
            fields: [
                AttachmentField(title: "Branch", value: "main", short: true),
                AttachmentField(title: "Commit", value: "abc123", short: true),
                AttachmentField(title: "Duration", value: "5m 32s", short: true),
                AttachmentField(title: "Status", value: ":white_check_mark: Success", short: true)
            ]
        )
    ]
)
try await client.send(message)
```

**With custom username and icon:**

```swift
let message = Message(
    username: "DeployBot",
    iconEmoji: ":rocket:",
    text: "Deployment complete!",
    attachments: [
        Attachment(
            color: "#36a64f",
            title: "Build #123",
            text: "Succeeded in 5m 32s"
        )
    ]
)
try await client.send(message)
```

### Message with Card Props

Mattermost supports displaying custom content in the RHS sidebar via `props.card`:

```swift
let message = Message(
    text: "We won a new deal!",
    props: Props(card: "Salesforce Opportunity Information:\\n\\n**Amount:** $300,020.00\\n**Close Date:** 2025-01-15\\n**Sales Rep:** John Doe")
)
try await client.send(message)
```

### Message with Priority

Mattermost supports urgent and important message priorities:

```swift
let message = Message(
    text: "Critical incident!",
    priority: Priority(
        priority: .urgent,
        requestedAck: true,
        persistentNotifications: true
    )
)
try await client.send(message)
```

**Important priority:**

```swift
let message = Message(
    text: "Important announcement",
    priority: Priority(priority: .important)
)
try await client.send(message)
```

### Message with Actions

Interactive buttons for user actions:

```swift
let message = Message(
    text: "Approval required for production deployment",
    attachments: [
        Attachment(
            text: "Deploy to production?",
            actions: [
                Action(
                    name: "approve",
                    text: "Approve",
                    style: "primary",
                    url: "https://example.com/approve"
                ),
                Action(
                    name: "reject",
                    text: "Reject",
                    style: "danger",
                    url: "https://example.com/reject"
                )
            ]
        )
    ]
)
try await client.send(message)
```

### Message with Rich Attachments

Complete attachment with all available fields:

```swift
let message = Message(
    username: "CI/CD Bot",
    iconURL: "https://example.com/ci-icon.png",
    text: "Build notification",
    attachments: [
        Attachment(
            fallback: "Build #123 succeeded",
            color: "#36a64f",
            pretext: "Build process completed",
            authorName: "Jenkins",
            authorLink: "https://jenkins.example.com",
            authorIcon: "https://example.com/jenkins-icon.png",
            title: "Build #123",
            titleLink: "https://jenkins.example.com/job/123",
            text: "All tests passed successfully",
            fields: [
                AttachmentField(title: "Branch", value: "feature/new-api", short: true),
                AttachmentField(title: "Commit", value: "a1b2c3d", short: true),
                AttachmentField(title: "Duration", value: "5m 32s", short: true),
                AttachmentField(title: "Tests", value: "156 passed", short: true)
            ],
            imageURL: "https://example.com/build-graph.png",
            thumbURL: "https://example.com/thumb.png",
            footer: "Jenkins CI",
            footerIcon: "https://example.com/jenkins.png"
        )
    ]
)
try await client.send(message)
```

## Message Properties

```swift
public struct Message: Sendable, Codable {
    public var text: String?              // Markdown-formatted message
    public var channel: String?           // Override default channel
    public var username: String?          // Override bot username
    public var iconEmoji: String?         // e.g., ":rocket:"
    public var iconURL: String?           // Override bot icon with image URL
    public var attachments: [Attachment]?  // Message attachments
    public var props: Props?              // Mattermost metadata
    public var type: String?              // Post type (must begin with "custom_")
    public var priority: Priority?        // Message priority
}
```

## Attachment Properties

```swift
public struct Attachment: Sendable, Codable {
    public var fallback: String?          // Plain-text summary
    public var color: String?             // Hex color code
    public var pretext: String?           // Text above attachment
    public var authorName: String?        // Author name
    public var authorLink: String?        // Author link
    public var authorIcon: String?        // Author icon URL
    public var title: String?             // Attachment title
    public var titleLink: String?         // Title link
    public var text: String?              // Attachment text (Markdown)
    public var fields: [AttachmentField]? // Attachment fields
    public var imageURL: String?          // Image URL
    public var thumbURL: String?          // Thumbnail URL
    public var footer: String?            // Footer text
    public var footerIcon: String?        // Footer icon URL
    public var actions: [Action]?         // Interactive buttons
}
```

## Props (Mattermost-Specific)

Mattermost supports custom metadata via the `props` field:

```swift
public struct Props: Sendable, Codable {
    public var card: String?              // RHS sidebar content
    public var additionalProperties: [String: AnyCodable]?  // Additional dynamic properties
}
```

The `card` property displays formatted content in the Mattermost RHS (Right Hand Side) sidebar when clicking on the message.

## Priority (Mattermost-Specific)

Message priority for urgent and important notifications:

```swift
public struct Priority: Sendable, Codable {
    public enum Level: String, Codable {
        case important                    // Important message
        case urgent                       // Urgent message
    }

    public var priority: Level            // Priority level
    public var requestedAck: Bool?        // Request acknowledgment
    public var persistentNotifications: Bool?  // Persistent notifications
}
```

## Error Handling

```swift
do {
    try await client.send(message)
} catch MattermostError.invalidURL(let url) {
    print("Invalid URL: \(url)")
} catch MattermostError.invalidResponse(let code, let body) {
    print("HTTP \(code): \(body ?? "No body")")
} catch MattermostError.encodingError(let error) {
    print("Failed to encode message: \(error)")
} catch MattermostError.networkError(let error) {
    print("Network error: \(error)")
}
```

## Differences from Slack

| Feature | SlackKit | MattermostKit |
|---------|----------|---------------|
| Block Kit | ✅ Full support | ❌ NOT supported |
| Message Threading | ✅ `thread_ts` | ❌ Not available |
| Attachments | ✅ Slack format | ✅ **Slack-compatible** |
| Custom Metadata | ❌ No | ✅ `props.card` |
| Message Priority | ❌ No | ✅ `priority` |

**Note:** MattermostKit does NOT support Slack's Block Kit. Use Markdown formatting in the `text` field and `attachments` for rich messages.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Built with [Swift](https://swift.org)
- Uses [Mattermost Incoming Webhooks](https://developers.mattermost.com/integrate/webhooks/incoming/)
- Inspired by [SlackKit](https://github.com/diegotl/SlackKit)

## Resources

- [Mattermost API Documentation](https://developers.mattermost.com/)
- [Incoming Webhooks](https://developers.mattermost.com/integrate/webhooks/incoming/)
- [Message Attachments](https://developers.mattermost.com/integrate/reference/message-attachments/)
- [Message Priority](https://developers.mattermost.com/integrate/reference/message-priority/)
