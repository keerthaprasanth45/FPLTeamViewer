import UIKit

/// Team row laid out in `Main.storyboard`.
/// Code here only binds data and applies `AppTheme` — layout lives in Interface Builder
/// so the cell can be tweaked visually without rewriting constraints.
final class TeamCell: UITableViewCell {
    static let reuseIdentifier = "TeamCell"

    // MARK: - Storyboard outlets

    @IBOutlet private weak var accentView: UIView!
    @IBOutlet private weak var badgeView: UIView!
    @IBOutlet private weak var badgeLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var shortNameLabel: UILabel!
    @IBOutlet private weak var playerCountContainer: UIView!
    @IBOutlet private weak var playerCountLabel: UILabel!

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        applyTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        accessoryType = .disclosureIndicator
    }

    // MARK: - Configuration

    func configure(with team: Team) {
        nameLabel.text = team.name
        shortNameLabel.text = team.shortName
        badgeLabel.text = team.shortName
        let playerText = team.playerCount == 1 ? "1 player" : "\(team.playerCount) players"
        playerCountLabel.text = playerText
        accessibilityLabel = "\(team.name), \(team.shortName), \(playerText)"
    }

    // MARK: - Theme

    /// Fonts and corner radii are applied in code so Dynamic Type and the theme
    /// stay in sync even if the storyboard uses placeholder system fonts.
    private func applyTheme() {
        backgroundColor = AppTheme.Color.card
        contentView.backgroundColor = AppTheme.Color.card
        accessoryType = .disclosureIndicator
        tintColor = AppTheme.Color.pitch

        accentView.backgroundColor = AppTheme.Color.pitch

        badgeView.backgroundColor = AppTheme.Color.pitchMuted
        badgeView.applyThemeCornerRadius(AppTheme.Radius.badge)
        badgeLabel.font = AppTheme.Font.badge()
        badgeLabel.textColor = AppTheme.Color.pitch
        badgeLabel.adjustsFontForContentSizeCategory = true

        nameLabel.font = AppTheme.Font.headline()
        nameLabel.textColor = AppTheme.Color.ink
        nameLabel.adjustsFontForContentSizeCategory = true

        shortNameLabel.font = AppTheme.Font.subhead()
        shortNameLabel.textColor = AppTheme.Color.secondaryInk
        shortNameLabel.adjustsFontForContentSizeCategory = true

        playerCountContainer.backgroundColor = AppTheme.Color.pitchMuted
        playerCountContainer.applyThemeCornerRadius(AppTheme.Radius.pill)
        playerCountLabel.font = AppTheme.Font.caption()
        playerCountLabel.textColor = AppTheme.Color.pitch
        playerCountLabel.adjustsFontForContentSizeCategory = true
    }
}
