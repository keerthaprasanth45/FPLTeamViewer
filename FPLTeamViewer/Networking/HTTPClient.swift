import Foundation

protocol HTTPClient {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

/// Thin URLSession wrapper so tests can stub networking without hitting the live FPL API.
struct URLSessionHTTPClient: HTTPClient {
    let session: URLSession

    func data(from url: URL) async throws -> (Data, URLResponse) {
        var request = URLRequest(url: url)
        request.setValue("FPLTeamViewer/1.0 (iOS Technical Exercise)", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 30
        return try await session.data(for: request)
    }
}
