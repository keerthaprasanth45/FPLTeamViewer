import XCTest
@testable import FPLTeamViewer

final class BootstrapMapperTests: XCTestCase {
    func testMapsTeamsWithPlayerCountsAndAlphabeticalOrder() throws {
        let bootstrap = try TestFixtures.bootstrap()

        XCTAssertEqual(bootstrap.teams.map(\.name), ["Arsenal", "Chelsea"])
        XCTAssertEqual(bootstrap.teams[0].shortName, "ARS")
        XCTAssertEqual(bootstrap.teams[0].playerCount, 5)
        XCTAssertEqual(bootstrap.teams[1].playerCount, 1)
    }

    func testGroupsSquadByPositionAndOrdersByPointsThenName() throws {
        let bootstrap = try TestFixtures.bootstrap()
        let arsenal = bootstrap.players(forTeamID: 1)
        let sections = BootstrapMapper.squadSections(from: arsenal)

        XCTAssertEqual(sections.map(\.position.pluralName), ["Goalkeepers", "Defenders", "Midfielders", "Forwards"])
        XCTAssertEqual(sections[1].players.map(\.name), ["Ben White", "William Saliba"])
        XCTAssertEqual(sections[2].players.first?.name, "Bukayo Saka")
        XCTAssertEqual(sections[2].players.first?.formattedPrice, "£10.0m")
    }

    func testHidesEmptyPositionSections() {
        let midfielder = Position(id: 3, name: "Midfielder", pluralName: "Midfielders", shortName: "MID", sortOrder: 2)
        let player = Player(
            id: 1,
            name: "Cole Palmer",
            webName: "Palmer",
            teamID: 2,
            position: midfielder,
            nowCost: 105,
            totalPoints: 90
        )

        let sections = BootstrapMapper.squadSections(from: [player])
        XCTAssertEqual(sections.count, 1)
        XCTAssertEqual(sections.first?.position.shortName, "MID")
    }

    func testPriceFormattingUsesTenthsOfMillions() {
        XCTAssertEqual(FPLFormatting.price(fromTenthsOfMillions: 55), "£5.5m")
        XCTAssertEqual(FPLFormatting.price(fromTenthsOfMillions: 100), "£10.0m")
    }
}
