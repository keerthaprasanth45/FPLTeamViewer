import Foundation

/// Owns one team's squad, including live search that regroups players by position.
@MainActor
final class SquadViewModel {

    // MARK: - Dependencies

    private let repository: FPLRepository
    private let teamID: Int
    private var allPlayers: [Player] = []

    // MARK: - Team identity

    let teamName: String
    let teamShortName: String

    // MARK: - Output

    private(set) var searchQuery = ""
    private(set) var sections: [SquadSection] = []
    private(set) var state: ContentLoadState<[Player]> = .loading {
        didSet { rebuildSections() }
    }

    var onChange: (() -> Void)?

    /// True when the user typed a query that matches nobody on this squad.
    var isSearchEmpty: Bool {
        !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && sections.isEmpty && state.value != nil
    }

    var isSquadEmpty: Bool {
        searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && (state.value?.isEmpty ?? false)
    }

    // MARK: - Init

    init(team: Team, repository: FPLRepository) {
        self.teamID = team.id
        self.teamName = team.name
        self.teamShortName = team.shortName
        self.repository = repository
    }

    // MARK: - Loading

    func loadInitial() async {
        if let cached = try? repository.loadCached() {
            apply(players: cached.players(forTeamID: teamID), refreshing: true)
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

    // MARK: - Search

    func updateSearchQuery(_ query: String) {
        searchQuery = query
        rebuildSections()
    }

    // MARK: - Private

    private func refresh(userInitiated: Bool) async {
        if let players = state.value {
            state = .refreshing(players)
        } else if userInitiated {
            state = .loading
        }

        do {
            let bootstrap = try await repository.fetchRemote()
            apply(players: bootstrap.players(forTeamID: teamID), refreshing: false)
        } catch {
            let message = LoadErrorPresenter.message(for: error)
            if let players = state.value {
                state = .refreshFailed(players, message)
            } else {
                state = .failed(message)
            }
        }
    }

    private func apply(players: [Player], refreshing: Bool) {
        if refreshing {
            state = .refreshing(players)
        } else {
            state = .loaded(players)
        }
    }

    private func rebuildSections() {
        allPlayers = state.value ?? []
        let filtered = PlayerFilter.filter(players: allPlayers, query: searchQuery)
        sections = BootstrapMapper.squadSections(from: filtered)
        onChange?()
    }
}
