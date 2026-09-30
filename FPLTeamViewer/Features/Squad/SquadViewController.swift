import UIKit

/// Squad list for one club. Prototype `PlayerCell` and chrome live in `Main.storyboard`.
final class SquadViewController: UIViewController {

    // MARK: - Dependencies

    private let viewModel: SquadViewModel

    // MARK: - Storyboard outlets

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    @IBOutlet private weak var statusView: StatusMessageView!
    @IBOutlet private weak var bannerView: RefreshBannerView!

    // MARK: - Search / refresh

    private let refreshControl = UIRefreshControl()
    private let searchController = UISearchController(searchResultsController: nil)

    // MARK: - Instantiation

    static func instantiate(viewModel: SquadViewModel) -> SquadViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(identifier: "SquadViewController") { coder in
            SquadViewController(coder: coder, viewModel: viewModel)
        }
    }

    private init?(coder: NSCoder, viewModel: SquadViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("Use SquadViewController.instantiate(viewModel:)")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.teamName
        navigationItem.largeTitleDisplayMode = .never
        configureSearch()
        configureTable()
        bindViewModel()
        Task { await viewModel.loadInitial() }
    }

    // MARK: - Setup

    private func configureSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search \(viewModel.teamShortName) players"
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.tintColor = AppTheme.Color.pitch
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func configureTable() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 96
        tableView.backgroundColor = AppTheme.Color.canvas
        view.backgroundColor = AppTheme.Color.canvas

        refreshControl.tintColor = AppTheme.Color.pitch
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl

        statusView.onRetry = { [weak self] in
            Task { await self?.viewModel.retry() }
        }
    }

    private func bindViewModel() {
        viewModel.onChange = { [weak self] in
            self?.render()
        }
        render()
    }

    // MARK: - Rendering

    private func render() {
        tableView.reloadData()
        let state = viewModel.state

        if !state.isRefreshing {
            refreshControl.endRefreshing()
            spinner.stopAnimating()
        }

        if viewModel.isSearchEmpty {
            tableView.isHidden = true
            statusView.isHidden = false
            spinner.stopAnimating()
            bannerView.setMessage(refreshBanner(for: state))
            statusView.configure(
                title: "No matching players",
                message: "Try a different name or position.",
                symbolName: "magnifyingglass",
                showsRetry: false
            )
            return
        }

        if viewModel.isSquadEmpty, case .loaded = state {
            tableView.isHidden = true
            statusView.isHidden = false
            bannerView.setMessage(nil)
            statusView.configure(
                title: "No players",
                message: "This team does not have any players in the current data.",
                symbolName: "person.3",
                showsRetry: true
            )
            return
        }

        switch state {
        case .loading:
            tableView.isHidden = true
            statusView.isHidden = true
            bannerView.setMessage(nil)
            spinner.startAnimating()

        case .loaded:
            tableView.isHidden = false
            statusView.isHidden = true
            bannerView.setMessage(nil)
            spinner.stopAnimating()

        case .failed(let message):
            tableView.isHidden = true
            statusView.isHidden = false
            bannerView.setMessage(nil)
            statusView.configure(
                title: "Couldn't load squad",
                message: message,
                symbolName: "wifi.exclamationmark",
                showsRetry: true
            )

        case .refreshing(let players):
            tableView.isHidden = players.isEmpty
            statusView.isHidden = true
            bannerView.setMessage(nil)
            if players.isEmpty {
                spinner.startAnimating()
            }

        case .refreshFailed(let players, let message):
            spinner.stopAnimating()
            if players.isEmpty {
                tableView.isHidden = true
                statusView.isHidden = false
                bannerView.setMessage(nil)
                statusView.configure(
                    title: "Couldn't load squad",
                    message: message,
                    symbolName: "wifi.exclamationmark",
                    showsRetry: true
                )
            } else {
                tableView.isHidden = false
                statusView.isHidden = true
                bannerView.setMessage("Couldn't refresh. Showing last saved data. \(message)")
            }
        }
    }

    private func refreshBanner(for state: ContentLoadState<[Player]>) -> String? {
        if case .refreshFailed(_, let message) = state {
            return "Couldn't refresh. Showing last saved data. \(message)"
        }
        return nil
    }

    // MARK: - Actions

    @objc private func didPullToRefresh() {
        Task { await viewModel.refresh() }
    }
}

// MARK: - UITableViewDataSource

extension SquadViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.sections[section].players.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionModel = viewModel.sections[section]
        return "\(sectionModel.position.pluralName) (\(sectionModel.players.count))"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlayerCell.reuseIdentifier, for: indexPath) as? PlayerCell else {
            return UITableViewCell()
        }
        let player = viewModel.sections[indexPath.section].players[indexPath.row]
        cell.configure(with: player)
        return cell
    }
}

// MARK: - UISearchResultsUpdating

extension SquadViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.updateSearchQuery(searchController.searchBar.text ?? "")
    }
}
