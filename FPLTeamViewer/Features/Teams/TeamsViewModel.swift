import Foundation

/// Owns team-list state: cache-first load, pull-to-refresh, and retry after a hard failure.
@MainActor
final class TeamsViewModel {

    // MARK: - Dependencies

    private let repository: FPLRepository

    // MARK: - Output

    private(set) var state: ContentLoadState<[Team]> = .loading {
        didSet { onChange?(state) }
    }

    var onChange: ((ContentLoadState<[Team]>) -> Void)?

    // MARK: - Init

    init(repository: FPLRepository) {
        self.repository = repository
    }

    // MARK: - Loading

    func loadInitial() async {
        // Show disk cache immediately so an offline launch is not a blank spinner.
        if let cached = try? repository.loadCached() {
            apply(teams: cached.teams, refreshing: true)
            await refresh(userInitiated: false)
            return
        }

        state = .loading
        await refresh(userInitiated: false)
    }

    func refresh() async {
        await refresh(userInitiated: true)
    }

    func retry() async {
        if state.value == nil {
            state = .loading
        }
        await refresh(userInitiated: true)
    }

    // MARK: - Private

    private func refresh(userInitiated: Bool) async {
        if let teams = state.value {
            state = .refreshing(teams)
        } else if userInitiated {
            state = .loading
        }

        do {
            let bootstrap = try await repository.fetchRemote()
            apply(teams: bootstrap.teams, refreshing: false)
        } catch {
            let message = LoadErrorPresenter.message(for: error)
            if let teams = state.value {
                // Keep the list visible; the view controller shows a banner instead of replacing it.
                state = .refreshFailed(teams, message)
            } else {
                state = .failed(message)
            }
        }
    }

    private func apply(teams: [Team], refreshing: Bool) {
        if refreshing {
            state = .refreshing(teams)
        } else {
            state = .loaded(teams)
        }
    }
}
