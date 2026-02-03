import Foundation

// MARK: - NetworkClient Protocol

/// A protocol defining the interface for making HTTP requests to the Mattermost API
public protocol NetworkClient: Sendable {
    /// Performs a POST request to the specified URL
    /// - Parameters:
    ///   - url: The URL to send the request to
    ///   - body: The request body data
    /// - Returns: An HTTP response containing the status code and response data
    /// - Throws: A network error if the request fails
    func post(url: URL, body: Data) async throws -> HTTPResponse
}

// MARK: - HTTPResponse

/// Represents an HTTP response
public struct HTTPResponse: Sendable {
    /// The HTTP status code
    public let statusCode: Int

    /// The response body data
    public let data: Data

    /// Initializes a new HTTP response
    /// - Parameters:
    ///   - statusCode: The HTTP status code
    ///   - data: The response body data
    public init(statusCode: Int, data: Data) {
        self.statusCode = statusCode
        self.data = data
    }

    /// Checks if the response indicates success (status code 200-299)
    public var isSuccess: Bool {
        (200...299).contains(statusCode)
    }
}
