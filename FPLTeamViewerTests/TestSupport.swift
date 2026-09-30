import Foundation
@testable import FPLTeamViewer

enum TestFixtures {
    static func bootstrapData() throws -> Data {
        let bundle = Bundle(for: TestBundleToken.self)
        guard let url = bundle.url(forResource: "bootstrap", withExtension: "json") else {
            throw FPLError.emptyCache
        }
        return try Data(contentsOf: url)
    }

    static func bootstrap() throws -> Bootstrap {
        let dto = try JSONDecoder().decode(BootstrapDTO.self, from: bootstrapData())
        return BootstrapMapper.map(dto)
    }

    static func httpSuccess(data: Data, statusCode: Int = 200) -> (Data, URLResponse) {
        let response = HTTPURLResponse(
            url: FPLAPI.bootstrapStatic,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        return (data, response)
    }
}

final class TestBundleToken {}

final class StubHTTPClient: HTTPClient {
    var handler: (URL) async throws -> (Data, URLResponse)

    init(handler: @escaping (URL) async throws -> (Data, URLResponse)) {
        self.handler = handler
    }

    func data(from url: URL) async throws -> (Data, URLResponse) {
        try await handler(url)
    }
}

final class InMemoryBootstrapCache: BootstrapCache {
    var stored: Data?
    var saveError: Error?

    func load() throws -> Data? {
        stored
    }

    func save(_ data: Data) throws {
        if let saveError {
            throw saveError
        }
        stored = data
    }
}

final class MockFPLRepository: FPLRepository {
    var cached: Bootstrap?
    var remoteResult: Result<Bootstrap, Error>
    private(set) var fetchCount = 0

    init(cached: Bootstrap? = nil, remoteResult: Result<Bootstrap, Error>) {
        self.cached = cached
        self.remoteResult = remoteResult
    }

    func loadCached() throws -> Bootstrap? {
        cached
    }

    func fetchRemote() async throws -> Bootstrap {
        fetchCount += 1
        return try remoteResult.get()
    }
}
