import XCTest
@testable import FPLTeamViewer

final class FPLRepositoryTests: XCTestCase {
    func testFetchRemoteDecodesCachesAndReturnsMappedData() async throws {
        let data = try TestFixtures.bootstrapData()
        let cache = InMemoryBootstrapCache()
        let client = StubHTTPClient { _ in TestFixtures.httpSuccess(data: data) }
        let repository = DefaultFPLRepository(client: client, cache: cache)

        let bootstrap = try await repository.fetchRemote()

        XCTAssertEqual(bootstrap.teams.count, 2)
        XCTAssertEqual(cache.stored, data)
        XCTAssertEqual(try repository.loadCached()?.teams.map(\.name), ["Arsenal", "Chelsea"])
    }

    func testFetchRemoteThrowsForNonHTTPSuccess() async {
        let cache = InMemoryBootstrapCache()
        let client = StubHTTPClient { _ in
            TestFixtures.httpSuccess(data: Data(), statusCode: 500)
        }
        let repository = DefaultFPLRepository(client: client, cache: cache)

        do {
            _ = try await repository.fetchRemote()
            XCTFail("Expected invalid response")
        } catch {
            XCTAssertEqual(error as? FPLError, .invalidResponse)
            XCTAssertNil(cache.stored)
        }
    }

    func testFetchRemoteDoesNotLoseSuccessWhenCacheWriteFails() async throws {
        let data = try TestFixtures.bootstrapData()
        let cache = InMemoryBootstrapCache()
        cache.saveError = FPLError.invalidResponse
        let client = StubHTTPClient { _ in TestFixtures.httpSuccess(data: data) }
        let repository = DefaultFPLRepository(client: client, cache: cache)

        let bootstrap = try await repository.fetchRemote()
        XCTAssertEqual(bootstrap.teams.first?.name, "Arsenal")
        XCTAssertNil(cache.stored)
    }

    func testLoadCachedReturnsNilWhenEmpty() throws {
        let repository = DefaultFPLRepository(client: StubHTTPClient { _ in TestFixtures.httpSuccess(data: Data()) }, cache: InMemoryBootstrapCache())
        XCTAssertNil(try repository.loadCached())
    }

    func testTransportErrorsAreSurfaced() async {
        struct TransportError: Error {}
        let client = StubHTTPClient { _ in throw TransportError() }
        let repository = DefaultFPLRepository(client: client, cache: InMemoryBootstrapCache())

        do {
            _ = try await repository.fetchRemote()
            XCTFail("Expected transport error")
        } catch {
            XCTAssertTrue(error is TransportError)
        }
    }
}
