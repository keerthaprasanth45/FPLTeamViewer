import XCTest
@testable import FPLTeamViewer

final class AppThemeTests: XCTestCase {
    func testPositionAccentsAreDistinct() {
        let gkp = Position(id: 1, name: "Goalkeeper", pluralName: "Goalkeepers", shortName: "GKP", sortOrder: 0)
        let def = Position(id: 2, name: "Defender", pluralName: "Defenders", shortName: "DEF", sortOrder: 1)
        let mid = Position(id: 3, name: "Midfielder", pluralName: "Midfielders", shortName: "MID", sortOrder: 2)
        let fwd = Position(id: 4, name: "Forward", pluralName: "Forwards", shortName: "FWD", sortOrder: 3)

        XCTAssertEqual(AppTheme.Color.accent(for: gkp), AppTheme.Color.goalkeeper)
        XCTAssertEqual(AppTheme.Color.accent(for: def), AppTheme.Color.defender)
        XCTAssertEqual(AppTheme.Color.accent(for: mid), AppTheme.Color.midfielder)
        XCTAssertEqual(AppTheme.Color.accent(for: fwd), AppTheme.Color.forward)
    }
}
