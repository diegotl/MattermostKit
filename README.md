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

- **Modern Result Builder API** - Declarative DSL for building messages with attachments
- **Type-Safe** - Full Codable support with compile-time safety
- **Attachments** - Slack-compatible attachment support for rich messages
- **Mattermost-Specific** - Support for `props.card` and message priority
- **Conditional Logic** - Native if/else and for-in support in builders
- **Swift 6** - Built with Swift 6, async/await, and strict concurrency

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

## Result Builder API

### Simple Message

```swift
let message = Message(text: "Deployment completed successfully!")
try await client.send(message)
```

### Message with Attachments

```swift
let message = Message(
    text: "Deployment complete!",
    username: "DeployBot",
    iconEmoji: ":rocket:"
) {
    Attachment(color: "#36a64f", title: "Build #123", text: "Succeeded in 5m 32s") {
        Field("Branch", value: "main")
        Field("Commit", value: "abc123")
        Field("Duration", value: "5m 32s")
        Field("Status", value: ":white_check_mark: Success")
    }
}
try await client.send(message)
```

### Multiple Attachments

```swift
let message = Message(
    text: "Deployment Summary",
    username: "DeployBot",
    iconEmoji: ":rocket:"
) {
    Attachment(color: "#36a64f", title: "Success") {
        Field("Environment", value: "production")
        Field("Duration", value: "5m 32s")
    }

    Attachment(color: "#36a64f", title: "Build Info") {
        Field("Branch", value: "main")
        Field("Commit", value: "abc123")
        Field("Tests", value: "156 passed")
    }
}
```

### Conditional Attachments

```swift
let hasWarnings = true
let hasErrors = false

let message = Message(username: "CIBot") {
    Attachment(color: "#36a64f", title: "Build Summary") {
        Field("Status", value: "Success")
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
```

### Message with Actions

```swift
let message = Message {
    Attachment(text: "Deploy to production?") {
        Field("Environment", value: "production")
        Field("Version", value: "v2.4.1")
    }

    Attachment.actions {
        Button(text: "Approve", style: "primary", url: approveURL)
        Button(text: "Reject", style: "danger", url: rejectURL)
        Button(text: "Defer", style: "default", url: deferURL)
    }
}
```

### Dynamic Fields with Loops

```swift
let testResults = [
    ("TestLogin", "passed"),
    ("TestAPI", "passed"),
    ("TestUI", "failed")
]

let message = Message {
    Attachment(title: "Test Results") {
        for (name, result) in testResults {
            Field(name, value: result, short: true)
        }
    }
}
```

### Message with Card Props

```swift
// Simple card with static text
let message = Message(
    text: "We won a new deal!",
    props: Props(card: """
    Salesforce Opportunity Information:

    **Amount:** $300,020.00
    **Close Date:** 2025-01-15
    **Sales Rep:** John Doe
    """)
)

// Card with dynamic properties using builder
let message = Message(
    text: "Deal updated!",
    props: Props(card: "Deal Information") {
        Property("amount", value: 300020)
        Property("stage", value: "Proposal")
        Property("is_closed", value: false)
    }
)

// Conditional properties
let includeDetails = true
let message = Message(
    text: "Opportunity created",
    props: Props(card: "Sales Info") {
        Property("opportunity_id", value: "12345")
        Property("account", value: "Acme Corp")

        if includeDetails {
            Property("estimated_value", value: 50000)
            Property("probability", value: 0.75)
        }
    }
)
```

### Message with Priority

```swift
// Urgent priority with acknowledgment
let message = Message(
    text: "Critical incident!",
    priority: Priority(
        priority: .urgent,
        requestedAck: true,
        persistentNotifications: true
    )
)

// Important priority
let message = Message(
    text: "Important announcement",
    priority: Priority(priority: .important)
)
```

### Confirmation Dialogs for Actions

```swift
// Simple confirmation
let confirm = Confirmation(
    title: "Are you sure?",
    text: "This will deploy to production",
    confirmText: "Deploy",
    denyText: "Cancel"
)

// Using result builder for custom buttons
let confirm = Confirmation(
    title: "Confirm Deployment",
    text: "This action cannot be undone"
) {
    ConfirmButton(text: "Yes, Deploy", style: "primary")
    DenyButton(text: "No, Cancel")
}

let message = Message {
    Attachment.actions {
        Button(text: "Deploy", style: "primary", url: deployURL, confirm: confirm)
        Button(text: "Cancel", style: "danger", url: cancelURL)
    }
}
```

### Complex Message with All Features

```swift
let message = Message(
    username: "CI/CD Bot",
    iconURL: "https://example.com/ci-icon.png",
    text: "Build notification"
) {
    Attachment(
        color: "#36a64f",
        title: "Build #123",
        pretext: "Build process completed",
        authorName: "Jenkins",
        authorLink: "https://jenkins.example.com",
        authorIcon: "https://example.com/jenkins-icon.png",
        titleLink: "https://jenkins.example.com/job/123",
        imageURL: "https://example.com/build-graph.png",
        thumbURL: "https://example.com/thumb.png",
        footer: "Jenkins CI",
        footerIcon: "https://example.com/jenkins.png"
    ) {
        Field("Branch", value: "feature/new-api", short: true)
        Field("Commit", value: "a1b2c3d", short: true)
        Field("Duration", value: "5m 32s", short: true)
        Field("Tests", value: "156 passed", short: true)
    }
}
```

### Confirmation Dialogs for Actions

```swift
let confirm = Confirmation(
    title: "Are you sure?",
    text: "This will deploy to production",
    confirmText: "Deploy",
    denyText: "Cancel"
)

let message = Message {
    Attachment.actions {
        Button(text: "Deploy", style: "primary", url: deployURL, confirm: confirm)
        Button(text: "Cancel", style: "danger", url: cancelURL)
    }
}
```

## Builder API Reference

### Message Builder

```swift
Message(
    text: "Message text",
    username: "Bot Name",
    iconEmoji: ":robot_face:"
) {
    // Attachments via @AttachmentBuilder
    Attachment(title: "Title") { ... }
}
```

### Attachment Builder

```swift
Attachment(
    color: "#36a64f",
    title: "Title",
    text: "Description"
) {
    // Fields via @FieldBuilder
    Field("Key", value: "Value")
}
```

### Actions Builder

```swift
Attachment.actions {
    // Actions via @ActionBuilder
    Button(text: "Click", url: url)
}
```

### Props Builder

```swift
Props(card: "Card content") {
    // Properties via @PropsBuilder
    Property("key", value: "value")
    Property("number", value: 42)
}
```

### Confirmation Builder

```swift
Confirmation(
    title: "Confirm?",
    text: "Are you sure?"
) {
    // Components via @ConfirmationBuilder
    ConfirmButton(text: "Yes", style: "primary")
    DenyButton(text: "No")
}
```

### Convenience Functions

```swift
// Field with short=true by default
Field("Branch", value: "main")

// Button action
Button(text: "Approve", style: "primary", url: "https://example.com")

// Properties (various types)
Property("name", value: "text")
Property("count", value: 42)
Property("enabled", value: true)
Property("metadata", value: ["key": .string("value")])

// Confirmation components
ConfirmButton(text: "Yes", style: "primary")
DenyButton(text: "No")

// Actions-only attachment
Attachment.actions {
    Button(text: "View", url: viewURL)
    Button(text: "Dismiss", style: "danger", url: dismissURL)
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

## API Reference

### Message

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

### Attachment

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

### Props (Mattermost-Specific)

```swift
public struct Props: Sendable, Codable {
    public var card: String?              // RHS sidebar content
    public var additionalProperties: [String: AnyCodable]?
}
```

### Priority (Mattermost-Specific)

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
