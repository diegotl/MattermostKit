// MARK: - MattermostKit

/// MattermostKit provides a modern Swift interface for sending messages to Mattermost via Incoming Webhooks.
///
/// ## Overview
///
/// MattermostKit enables Swift applications to send rich, formatted messages to Mattermost channels
/// using Incoming Webhooks. It supports Slack-compatible attachments for rich message formatting
/// and Mattermost-specific features like `props.card` and message priority.
///
/// ## Usage
///
/// ```swift
/// import MattermostKit
///
/// // Create a client with your webhook URL
/// let client = try MattermostWebhookClient.create(
///     webhookURLString: "https://mattermost.server.com/hooks/xxx"
/// )
///
/// // Send a simple text message
/// try await client.send(Message(text: "Hello, Mattermost!"))
///
/// // Send a message with attachments
/// let message = Message(
///     username: "My Bot",
///     iconEmoji: ":rocket:",
///     text: "Deployment complete!",
///     attachments: [
///         Attachment(
///             color: "#36a64f",
///             title: "Build #123",
///             text: "Succeeded in 5m 32s",
///             fields: [
///                 AttachmentField(title: "Branch", value: "main", short: true),
///                 AttachmentField(title: "Commit", value: "abc123", short: true)
///             ]
///         )
///     ]
/// )
/// try await client.send(message)
/// ```
///
/// ## Features
///
/// - **Async/Await**: Modern Swift concurrency support
/// - **Type-Safe**: Full Swift type safety with Codable models
/// - **Attachments**: Slack-compatible attachment support
/// - **Sendable**: Full Swift 6 concurrency support
/// - **Testable**: Protocol-based networking for easy testing
