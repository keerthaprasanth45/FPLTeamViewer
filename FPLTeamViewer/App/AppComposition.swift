import UIKit

/// Composition root: builds the object graph once so view controllers stay unaware of
/// networking and cache details.
@MainActor
enum AppComposition {

    // MARK: - Root

    static func makeRootViewController() -> UIViewController {
        let repository = makeRepository()
        let viewModel = TeamsViewModel(repository: repository)
        let teamsViewController = TeamsViewController.instantiate(viewModel: viewModel) { team in
            makeSquadViewController(team: team, repository: repository)
        }
        let navigationController = UINavigationController(rootViewController: teamsViewController)
        navigationController.navigationBar.prefersLargeTitles = true
        return navigationController
    }

    // MARK: - Screens

    static func makeSquadViewController(team: Team, repository: FPLRepository) -> SquadViewController {
        let viewModel = SquadViewModel(team: team, repository: repository)
        return SquadViewController.instantiate(viewModel: viewModel)
    }

    // MARK: - Services

    static func makeRepository() -> FPLRepository {
        DefaultFPLRepository(
            client: URLSessionHTTPClient(session: .shared),
            cache: FileBootstrapCache()
        )
    }
}
