#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Foundation

// MARK: - URLSessionNetworkClient

/// A URLSession-based implementation of NetworkClient
public actor URLSessionNetworkClient: NetworkClient {
    private let session: URLSession

    /// Initializes a new URLSession network client
    /// - Parameter session: The URLSession to use for requests (defaults to shared)
    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func post(url: URL, body: Data) async throws -> HTTPResponse {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw MattermostError.invalidResponse(statusCode: -1, body: "Invalid response type")
            }

            return HTTPResponse(statusCode: httpResponse.statusCode, data: data)
        } catch let error as MattermostError {
            throw error
        } catch let error as NSError {
            // Wrap NSError in MattermostError
            throw MattermostError.networkError(error)
        }
    }
}
