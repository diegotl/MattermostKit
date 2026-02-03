import Testing
import Foundation
@testable import MattermostKit

// MARK: - MattermostWebhookClient Tests

@Test("Send simple text message successfully")
func sendSimpleTextMessage() async throws {
    // Arrange
    let webhookURL = URL(string: "https://mattermost.server.com/hooks/xxx")!
    let mockClient = MockNetworkClient()
    let mattermostClient = MattermostWebhookClient(
        webhookURL: webhookURL,
        networkClient: mockClient
    )

    // Mock a successful response
    let responseData = "ok".data(using: .utf8)!
    await mockClient.addResponse(statusCode: 200, data: responseData)

    // Act
    let message = Message(text: "Hello, Mattermost!")
    let response = try await mattermostClient.send(message)

    // Assert
    #expect(response.ok == true)
    let requests = await mockClient.requests
    #expect(requests.count == 1)

    // Verify the request body contains the text
    let requestBody = try JSONDecoder().decode([String: String].self, from: requests[0].body)
    #expect(requestBody["text"] == "Hello, Mattermost!")
}

@Test("Send message with attachments")
func sendMessageWithAttachments() async throws {
    // Arrange
    let webhookURL = URL(string: "https://mattermost.server.com/hooks/xxx")!
    let mockClient = MockNetworkClient()
    let mattermostClient = MattermostWebhookClient(
        webhookURL: webhookURL,
        networkClient: mockClient
    )

    // Mock a successful response
    let responseData = "ok".data(using: .utf8)!
    await mockClient.addResponse(statusCode: 200, data: responseData)

    // Act
    let message = Message(
        text: "Deployment complete!",
        username: "DeployBot",
        iconEmoji: ":rocket:",
        attachments: [
            Attachment(
                color: "#36a64f",
                title: "Build #123",
                text: "Succeeded in 5m 32s",
                fields: [
                    AttachmentField(title: "Branch", value: "main", short: true),
                    AttachmentField(title: "Commit", value: "abc123", short: true)
                ]
            )
        ]
    )
    let response = try await mattermostClient.send(message)

    // Assert
    #expect(response.ok == true)
    let requests = await mockClient.requests
    #expect(requests.count == 1)
}

@Test("Send message with card props")
func sendMessageWithCardProps() async throws {
    // Arrange
    let webhookURL = URL(string: "https://mattermost.server.com/hooks/xxx")!
    let mockClient = MockNetworkClient()
    let mattermostClient = MattermostWebhookClient(
        webhookURL: webhookURL,
        networkClient: mockClient
    )

    // Mock a successful response
    let responseData = "ok".data(using: .utf8)!
    await mockClient.addResponse(statusCode: 200, data: responseData)

    // Act
    let message = Message(
        text: "Deal closed!",
        props: Props(card: "Sales details...")
    )
    let response = try await mattermostClient.send(message)

    // Assert
    #expect(response.ok == true)
    let requests = await mockClient.requests
    #expect(requests.count == 1)
}

@Test("Send message with priority")
func sendMessageWithPriority() async throws {
    // Arrange
    let webhookURL = URL(string: "https://mattermost.server.com/hooks/xxx")!
    let mockClient = MockNetworkClient()
    let mattermostClient = MattermostWebhookClient(
        webhookURL: webhookURL,
        networkClient: mockClient
    )

    // Mock a successful response
    let responseData = "ok".data(using: .utf8)!
    await mockClient.addResponse(statusCode: 200, data: responseData)

    // Act
    let message = Message(
        text: "Critical incident!",
        priority: Priority(
            priority: .urgent,
            requestedAck: true,
            persistentNotifications: true
        )
    )
    let response = try await mattermostClient.send(message)

    // Assert
    #expect(response.ok == true)
    let requests = await mockClient.requests
    #expect(requests.count == 1)
}

@Test("Handle HTTP error status")
func handleHTTPErrorStatus() async throws {
    // Arrange
    let webhookURL = URL(string: "https://mattermost.server.com/hooks/xxx")!
    let mockClient = MockNetworkClient()
    let mattermostClient = MattermostWebhookClient(
        webhookURL: webhookURL,
        networkClient: mockClient
    )

    // Mock a 404 response
    let responseData = "Not Found".data(using: .utf8)!
    await mockClient.addResponse(statusCode: 404, data: responseData)

    // Act & Assert
    let message = Message(text: "Test")
    await #expect(throws: MattermostError.self) {
        try await mattermostClient.send(message)
    }
}

@Test("Handle network error")
func handleNetworkError() async throws {
    // Arrange
    let webhookURL = URL(string: "https://mattermost.server.com/hooks/xxx")!
    let mockClient = MockNetworkClient()
    let mattermostClient = MattermostWebhookClient(
        webhookURL: webhookURL,
        networkClient: mockClient
    )

    // Mock a network error
    let networkError = NSError(domain: "NSURLErrorDomain", code: -1004, userInfo: nil)
    await mockClient.addError(networkError)

    // Act & Assert
    let message = Message(text: "Test")
    await #expect(throws: MattermostError.self) {
        try await mattermostClient.send(message)
    }
}

@Test("Initialize with URL string")
func initializeWithURLString() async throws {
    // Arrange & Act
    let webhookURLString = "https://mattermost.server.com/hooks/xxx"
    _ = try MattermostWebhookClient.create(
        webhookURLString: webhookURLString
    )

    // Assert - client was created successfully (no error thrown)
    #expect(true)
}

@Test("Throw error for invalid URL string")
func throwErrorForInvalidURLString() async throws {
    // Arrange & Act & Assert
    let invalidURL = "not a valid url"
    #expect(throws: MattermostError.self) {
        try MattermostWebhookClient.create(webhookURLString: invalidURL)
    }
}
