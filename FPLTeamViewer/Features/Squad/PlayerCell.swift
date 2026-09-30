import UIKit

/// Player row laid out in `Main.storyboard`.
/// Position chips are coloured from `AppTheme` so GKP/DEF/MID/FWD are easy to scan.
final class PlayerCell: UITableViewCell {
    static let reuseIdentifier = "PlayerCell"

    // MARK: - Storyboard outlets

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var positionContainer: UIView!
    @IBOutlet private weak var positionLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var pointsContainer: UIView!
    @IBOutlet private weak var pointsLabel: UILabel!
    @IBOutlet private weak var pointsCaptionLabel: UILabel!

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        applyTheme()
    }

    // MARK: - Configuration

    func configure(with player: Player) {
        nameLabel.text = player.name
        positionLabel.text = player.position.name
        priceLabel.text = player.formattedPrice
        pointsLabel.text = "\(player.totalPoints)"
        positionContainer.backgroundColor = AppTheme.Color.accent(for: player.position)
        accessibilityLabel = "\(player.name), \(player.position.name), \(player.formattedPrice), \(player.totalPoints) points"
    }

    // MARK: - Theme

    private func applyTheme() {
        selectionStyle = .none
        backgroundColor = AppTheme.Color.card
        contentView.backgroundColor = AppTheme.Color.card

        nameLabel.font = AppTheme.Font.headline()
        nameLabel.textColor = AppTheme.Color.ink
        nameLabel.adjustsFontForContentSizeCategory = true

        positionContainer.applyThemeCornerRadius(AppTheme.Radius.chip)
        positionLabel.font = AppTheme.Font.caption()
        positionLabel.textColor = .white
        positionLabel.adjustsFontForContentSizeCategory = true

        priceLabel.font = AppTheme.Font.subhead()
        priceLabel.textColor = AppTheme.Color.secondaryInk
        priceLabel.adjustsFontForContentSizeCategory = true

        pointsContainer.backgroundColor = AppTheme.Color.pitchMuted
        pointsContainer.applyThemeCornerRadius(AppTheme.Radius.points)
        pointsLabel.font = AppTheme.Font.points()
        pointsLabel.textColor = AppTheme.Color.gold
        pointsLabel.adjustsFontForContentSizeCategory = true
        pointsCaptionLabel.font = AppTheme.Font.caption()
        pointsCaptionLabel.textColor = AppTheme.Color.secondaryInk
        pointsCaptionLabel.adjustsFontForContentSizeCategory = true
        pointsCaptionLabel.text = "pts"
    }
}
