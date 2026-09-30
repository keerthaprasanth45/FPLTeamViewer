import XCTest
@testable import FPLTeamViewer

final class BootstrapDecodingTests: XCTestCase {
    func testDecodesRequiredFieldsAndIgnoresUnknownKeys() throws {
        let dto = try JSONDecoder().decode(BootstrapDTO.self, from: TestFixtures.bootstrapData())

        XCTAssertEqual(dto.teams.count, 2)
        XCTAssertEqual(dto.teams[0].name, "Arsenal")
        XCTAssertEqual(dto.teams[0].shortName, "ARS")
        XCTAssertEqual(dto.elementTypes.map(\.id), [1, 2, 3, 4])
        XCTAssertEqual(dto.elements.count, 6)
        XCTAssertEqual(dto.elements[1].webName, "Saka")
        XCTAssertEqual(dto.elements[1].nowCost, 100)
        XCTAssertEqual(dto.elements[1].totalPoints, 80)
    }

    func testDecodingInvalidPayloadThrowsDecodingFailedFromRepository() async {
        let client = StubHTTPClient { _ in
            let data = Data("{".utf8)
            return TestFixtures.httpSuccess(data: data)
        }
        let repository = DefaultFPLRepository(client: client, cache: InMemoryBootstrapCache())

        do {
            _ = try await repository.fetchRemote()
            XCTFail("Expected decoding to fail")
        } catch {
            XCTAssertEqual(error as? FPLError, .decodingFailed)
        }
    }
}
