import XCTest
@testable import FPLTeamViewer

final class BootstrapCacheTests: XCTestCase {
    func testRoundTripsDataOnDisk() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        let fileURL = directory.appendingPathComponent("bootstrap-static.json")
        let cache = FileBootstrapCache(fileURL: fileURL)
        let payload = try TestFixtures.bootstrapData()

        XCTAssertNil(try cache.load())
        try cache.save(payload)
        XCTAssertEqual(try cache.load(), payload)
    }

    func testMissingFileReturnsNil() throws {
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("missing-\(UUID().uuidString).json")
        let cache = FileBootstrapCache(fileURL: fileURL)
        XCTAssertNil(try cache.load())
    }
}
