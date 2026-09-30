import XCTest
@testable import FPLTeamViewer

final class PlayerFilterTests: XCTestCase {
    func testEmptyQueryReturnsAllPlayers() throws {
        let players = try TestFixtures.bootstrap().players(forTeamID: 1)
        XCTAssertEqual(PlayerFilter.filter(players: players, query: "  ").count, 5)
    }

    func testFiltersByNameCaseInsensitively() throws {
        let players = try TestFixtures.bootstrap().players(forTeamID: 1)
        let result = PlayerFilter.filter(players: players, query: "saka")
        XCTAssertEqual(result.map(\.webName), ["Saka"])
    }

    func testFiltersByPositionShortName() throws {
        let players = try TestFixtures.bootstrap().players(forTeamID: 1)
        let result = PlayerFilter.filter(players: players, query: "def")
        XCTAssertEqual(Set(result.map(\.webName)), ["Saliba", "White"])
    }

    func testUnknownQueryReturnsEmptyArray() throws {
        let players = try TestFixtures.bootstrap().players(forTeamID: 1)
        XCTAssertTrue(PlayerFilter.filter(players: players, query: "zzz").isEmpty)
    }
}
