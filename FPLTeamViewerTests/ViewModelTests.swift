import XCTest
@testable import FPLTeamViewer

@MainActor
final class TeamsViewModelTests: XCTestCase {
    func testShowsCachedTeamsWhenOfflineRefreshFails() async throws {
        let bootstrap = try TestFixtures.bootstrap()
        let repository = MockFPLRepository(
            cached: bootstrap,
            remoteResult: .failure(NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet))
        )
        let viewModel = TeamsViewModel(repository: repository)

        await viewModel.loadInitial()

        guard case .refreshFailed(let teams, let message) = viewModel.state else {
            return XCTFail("Expected refresh failure with cached teams, got \(viewModel.state)")
        }
        XCTAssertEqual(teams.map(\.name), ["Arsenal", "Chelsea"])
        XCTAssertTrue(message.contains("offline"))
    }

    func testInitialFailureCanBeRetried() async throws {
        let bootstrap = try TestFixtures.bootstrap()
        let repository = MockFPLRepository(remoteResult: .failure(FPLError.invalidResponse))
        let viewModel = TeamsViewModel(repository: repository)

        await viewModel.loadInitial()
        guard case .failed = viewModel.state else {
            return XCTFail("Expected initial failure")
        }

        repository.remoteResult = .success(bootstrap)
        await viewModel.retry()

        guard case .loaded(let teams) = viewModel.state else {
            return XCTFail("Expected loaded state after retry")
        }
        XCTAssertEqual(teams.count, 2)
        XCTAssertEqual(repository.fetchCount, 2)
    }

    func testSuccessfulLoadAndEmptyTeams() async {
        let empty = Bootstrap(teams: [], players: [])
        let repository = MockFPLRepository(remoteResult: .success(empty))
        let viewModel = TeamsViewModel(repository: repository)

        await viewModel.loadInitial()

        guard case .loaded(let teams) = viewModel.state else {
            return XCTFail("Expected loaded empty list")
        }
        XCTAssertTrue(teams.isEmpty)
    }
}

@MainActor
final class SquadViewModelTests: XCTestCase {
    func testSearchUpdatesSectionsAsQueryChanges() async throws {
        let bootstrap = try TestFixtures.bootstrap()
        let arsenal = bootstrap.teams.first { $0.name == "Arsenal" }!
        let repository = MockFPLRepository(cached: bootstrap, remoteResult: .success(bootstrap))
        let viewModel = SquadViewModel(team: arsenal, repository: repository)

        await viewModel.loadInitial()
        XCTAssertEqual(viewModel.sections.count, 4)

        viewModel.updateSearchQuery("saka")
        XCTAssertEqual(viewModel.sections.count, 1)
        XCTAssertEqual(viewModel.sections.first?.players.first?.webName, "Saka")
        XCTAssertFalse(viewModel.isSearchEmpty)

        viewModel.updateSearchQuery("zzz")
        XCTAssertTrue(viewModel.sections.isEmpty)
        XCTAssertTrue(viewModel.isSearchEmpty)
    }

    func testRefreshFailureKeepsExistingSquad() async throws {
        let bootstrap = try TestFixtures.bootstrap()
        let arsenal = bootstrap.teams.first { $0.name == "Arsenal" }!
        let repository = MockFPLRepository(cached: bootstrap, remoteResult: .failure(FPLError.invalidResponse))
        let viewModel = SquadViewModel(team: arsenal, repository: repository)

        await viewModel.loadInitial()

        guard case .refreshFailed(let players, _) = viewModel.state else {
            return XCTFail("Expected refresh failure with existing players")
        }
        XCTAssertEqual(players.count, 5)
        XCTAssertEqual(viewModel.sections.first?.position.pluralName, "Goalkeepers")
    }
}

final class LoadErrorPresenterTests: XCTestCase {
    func testMapsURLAndDomainErrors() {
        let offline = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        XCTAssertTrue(LoadErrorPresenter.message(for: offline).contains("offline"))
        XCTAssertEqual(LoadErrorPresenter.message(for: FPLError.invalidResponse), "The server returned an unexpected response.")
    }
}
