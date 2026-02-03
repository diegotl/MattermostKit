import Foundation

// MARK: - MattermostWebhookClient

/// A client for sending messages to Mattermost via Incoming Webhooks
public final actor MattermostWebhookClient {
    private let webhookURL: URL
    private let networkClient: any NetworkClient
    private let encoder: JSONEncoder

    /// Initializes a new Mattermost webhook client
    /// - Parameters:
    ///   - webhookURL: The webhook URL
    ///   - networkClient: An optional custom network client (uses URLSession by default)
    ///   - encoder: An optional custom JSON encoder
    public init(
        webhookURL: URL,
        networkClient: (any NetworkClient)? = nil,
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.webhookURL = webhookURL
        self.networkClient = networkClient ?? URLSessionNetworkClient()
        self.encoder = encoder
    }

    /// Sends a message to the Mattermost webhook
    /// - Parameter message: The message to send
    /// - Returns: The response from Mattermost
    /// - Throws: A `MattermostError` if the message fails to send
    @discardableResult
    public func send(_ message: Message) async throws -> MattermostResponse {
        // Encode the message
        let body: Data
        do {
            body = try encoder.encode(message)
        } catch {
            throw MattermostError.encodingError(error)
        }

        // Send the request
        let response = try await networkClient.post(url: webhookURL, body: body)

        // Check for HTTP errors
        guard response.isSuccess else {
            let bodyString = String(data: response.data, encoding: .utf8)
            throw MattermostError.invalidResponse(
                statusCode: response.statusCode,
                body: bodyString
            )
        }

        // Decode the response
        // Mattermost webhooks return "ok" as plain text on success
        if let bodyString = String(data: response.data, encoding: .utf8),
           bodyString == "ok" {
            return MattermostResponse(ok: true)
        }

        // Try to decode as JSON error response
        let decoder = JSONDecoder()
        do {
            let mattermostResponse = try decoder.decode(MattermostResponse.self, from: response.data)

            if !mattermostResponse.ok {
                throw MattermostError.invalidMessage(
                    mattermostResponse.error ?? "Unknown error"
                )
            }

            return mattermostResponse
        } catch {
            throw MattermostError.networkError(error)
        }
    }
}

// MARK: - Factory Methods

extension MattermostWebhookClient {
    /// Creates a new Mattermost webhook client with a URL string
    /// - Parameter webhookURLString: The webhook URL as a string
    /// - Returns: A new Mattermost webhook client
    /// - Throws: A `MattermostError` if the URL string is invalid
    public static func create(webhookURLString: String) throws -> MattermostWebhookClient {
        guard let url = URL(string: webhookURLString) else {
            throw MattermostError.invalidURL(webhookURLString)
        }

        // Validate that the URL has a valid scheme and is properly formed
        guard url.scheme == "http" || url.scheme == "https" else {
            throw MattermostError.invalidURL(webhookURLString)
        }

        return MattermostWebhookClient(webhookURL: url)
    }
}
