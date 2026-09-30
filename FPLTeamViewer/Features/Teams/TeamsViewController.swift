import UIKit

/// Premier League team list. The table, prototype `TeamCell`, overlays, and constraints
/// are defined in `Main.storyboard`; this class owns behaviour (refresh, navigation, state).
final class TeamsViewController: UIViewController {

    // MARK: - Dependencies

    private let viewModel: TeamsViewModel
    private let makeSquad: (Team) -> UIViewController

    // MARK: - Storyboard outlets

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    @IBOutlet private weak var statusView: StatusMessageView!
    @IBOutlet private weak var bannerView: RefreshBannerView!

    // MARK: - State

    private let refreshControl = UIRefreshControl()
    private var teams: [Team] = []

    // MARK: - Instantiation

    /// Storyboard scenes cannot take custom `init` arguments, so we use the iOS 13+
    /// creator closure to inject the view model while still decoding the IB layout.
    static func instantiate(
        viewModel: TeamsViewModel,
        makeSquad: @escaping (Team) -> UIViewController
    ) -> TeamsViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(identifier: "TeamsViewController") { coder in
            TeamsViewController(coder: coder, viewModel: viewModel, makeSquad: makeSquad)
        }
    }

    private init?(
        coder: NSCoder,
        viewModel: TeamsViewModel,
        makeSquad: @escaping (Team) -> UIViewController
    ) {
        self.viewModel = viewModel
        self.makeSquad = makeSquad
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("Use TeamsViewController.instantiate(viewModel:makeSquad:)")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Premier League"
        navigationItem.largeTitleDisplayMode = .always
        configureTable()
        bindViewModel()
        Task { await viewModel.loadInitial() }
    }

    // MARK: - Setup

    private func configureTable() {
        // Prototype cells are registered by the storyboard via reuseIdentifier.
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 92
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
        viewModel.onChange = { [weak self] state in
            self?.render(state)
        }
        render(viewModel.state)
    }

    // MARK: - Rendering

    private func render(_ state: ContentLoadState<[Team]>) {
        teams = state.value ?? []
        tableView.reloadData()

        if state.isRefreshing {
            if refreshControl.isRefreshing == false && state.value == nil {
                spinner.startAnimating()
            }
        } else {
            refreshControl.endRefreshing()
            spinner.stopAnimating()
        }

        switch state {
        case .loading:
            tableView.isHidden = true
            statusView.isHidden = true
            bannerView.setMessage(nil)
            spinner.startAnimating()

        case .loaded(let teams):
            spinner.stopAnimating()
            bannerView.setMessage(nil)
            if teams.isEmpty {
                tableView.isHidden = true
                statusView.isHidden = false
                statusView.configure(
                    title: "No teams",
                    message: "The API did not return any Premier League teams.",
                    symbolName: "sportscourt",
                    showsRetry: true
                )
            } else {
                tableView.isHidden = false
                statusView.isHidden = true
            }

        case .failed(let message):
            tableView.isHidden = true
            statusView.isHidden = false
            bannerView.setMessage(nil)
            statusView.configure(
                title: "Couldn't load teams",
                message: message,
                symbolName: "wifi.exclamationmark",
                showsRetry: true
            )

        case .refreshing(let teams):
            tableView.isHidden = teams.isEmpty
            statusView.isHidden = true
            bannerView.setMessage(nil)
            if teams.isEmpty {
                spinner.startAnimating()
            }

        case .refreshFailed(let teams, let message):
            spinner.stopAnimating()
            if teams.isEmpty {
                tableView.isHidden = true
                statusView.isHidden = false
                bannerView.setMessage(nil)
                statusView.configure(
                    title: "Couldn't load teams",
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

    // MARK: - Actions

    @objc private func didPullToRefresh() {
        Task { await viewModel.refresh() }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension TeamsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        teams.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TeamCell.reuseIdentifier, for: indexPath) as? TeamCell else {
            return UITableViewCell()
        }
        cell.configure(with: teams[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let team = teams[indexPath.row]
        navigationController?.pushViewController(makeSquad(team), animated: true)
    }
}
