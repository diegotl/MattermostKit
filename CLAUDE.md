# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

**Build:**
```bash
swift build
```

**Run tests:**
```bash
swift test
```

**Run specific test:**
```bash
swift test --filter "testName"
```

**Run tests with code coverage:**
```bash
swift test --enable-code-coverage
```

**Build in verbose mode:**
```bash
swift build -v
```

## Architecture

MattermostKit is a Swift 6 package for sending messages to Mattermost via Incoming Webhooks. The architecture follows a protocol-based design for testability and uses Swift 6 strict concurrency throughout.

### Core Design

- **Actor-based client**: `MattermostWebhookClient` is an `actor` for thread-safe async operations
- **Protocol abstraction**: `NetworkClient` protocol enables dependency injection for testing
- **Slack-compatible**: Uses the same attachment schema as Slack for compatibility
- **Mattermost-specific**: Supports `Props.card` (sidebar content) and `Priority` (urgent/important)

### Key Differences from Slack

Mattermost webhooks **do not support** Slack's Block Kit. Only use:
- Markdown text in the `text` field
- Slack-compatible `attachments` array
- Mattermost-specific `props.card` and `priority`

### Module Structure

**Client Layer** (`Sources/MattermostKit/Client/`):
- `MattermostWebhookClient` - Main actor that encodes and sends messages
- `NetworkClient` protocol - Abstraction for HTTP POST operations
- `URLSessionNetworkClient` - Default URLSession-based implementation

**Models** (`Sources/MattermostKit/Models/`):
- `Message` - Core message with `text`, `username`, `iconEmoji`, `attachments`, `props`, `priority`
- `Attachment` - Slack-compatible attachments with fields, colors, actions
- `Props` - Mattermost metadata (primarily `card` for RHS sidebar)
- `Priority` - Message priority levels (`.urgent`, `.important`)

**Error Handling** (`Sources/MattermostKit/Errors/`):
- `MattermostError` enum covers: `invalidURL`, `networkError`, `invalidResponse`, `encodingError`, `invalidMessage`
- Note: No `rateLimitExceeded` (not applicable to Mattermost webhooks)

### Testing

Tests use `MockNetworkClient` actor (`Tests/MattermostKitTests/MockNetworkClient.swift`) which:
- Captures all requests for verification
- Queues predefined responses or errors
- Implements `NetworkClient` protocol

### Codable Patterns

All models use `CodingKeys` to convert camelCase Swift properties to snake_case API fields (e.g., `iconEmoji` → `icon_emoji`).

## Platform Requirements

- macOS 12.0+, iOS 15.0+, tvOS 15.0+, watchOS 8.0+
- Swift 6.2+
- Zero external dependencies
