import Foundation
@testable import MattermostKit

// MARK: - MockNetworkClient

/// A mock network client for testing
public actor MockNetworkClient: NetworkClient {
    /// Captured requests made to this client
    public private(set) var requests: [(url: URL, body: Data)] = []

    /// Responses to return for each request
    public var responses: [Result<HTTPResponse, Error>] = []

    /// Creates a new mock network client
    public init() {}

    /// Adds a successful response
    /// - Parameters:
    ///   - statusCode: The status code to return
    ///   - data: The response body data
    public func addResponse(statusCode: Int, data: Data) {
        responses.append(.success(HTTPResponse(statusCode: statusCode, data: data)))
    }

    /// Adds a failed response
    /// - Parameter error: The error to throw
    public func addError(_ error: Error) {
        responses.append(.failure(error))
    }

    public func post(url: URL, body: Data) async throws -> HTTPResponse {
        // Capture the request
        requests.append((url, body))

        // Return the next response
        guard !responses.isEmpty else {
            throw MattermostError.networkError(
                NSError(domain: "MockNetworkClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "No response configured"])
            )
        }

        let result = responses.removeFirst()
        do {
            return try result.get()
        } catch let error as MattermostError {
            throw error
        } catch {
            throw MattermostError.networkError(error)
        }
    }

    /// Resets the mock client
    public func reset() {
        requests.removeAll()
        responses.removeAll()
    }
}
