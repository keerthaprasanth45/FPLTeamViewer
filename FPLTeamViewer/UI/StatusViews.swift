import UIKit

// MARK: - Empty / error state

/// Full-screen placeholder used for loading failures, empty lists, and empty search.
/// Layout is built in code because this view is shared by both storyboard screens
/// as a custom class dropped onto `Main.storyboard`.
final class StatusMessageView: UIView {
    var onRetry: (() -> Void)?

    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let retryButton = UIButton(type: .system)
    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func configure(title: String, message: String, symbolName: String, showsRetry: Bool) {
        titleLabel.text = title
        messageLabel.text = message
        imageView.image = UIImage(systemName: symbolName)
        retryButton.isHidden = !showsRetry
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = AppTheme.Color.canvas

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = AppTheme.Color.pitch
        imageView.contentMode = .scaleAspectFit
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 40, weight: .medium)

        titleLabel.font = AppTheme.Font.screenTitle()
        titleLabel.textColor = AppTheme.Color.ink
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontForContentSizeCategory = true

        messageLabel.font = AppTheme.Font.body()
        messageLabel.textColor = AppTheme.Color.secondaryInk
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.adjustsFontForContentSizeCategory = true

        retryButton.setTitle("Retry", for: .normal)
        retryButton.titleLabel?.font = AppTheme.Font.button()
        retryButton.tintColor = AppTheme.Color.pitch
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)

        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = AppTheme.Spacing.sm
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(retryButton)

        addSubview(stackView)

        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 48),
            imageView.widthAnchor.constraint(equalToConstant: 48),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AppTheme.Spacing.lg),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -AppTheme.Spacing.lg),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: AppTheme.Spacing.lg),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -AppTheme.Spacing.lg)
        ])
    }

    @objc private func retryTapped() {
        onRetry?()
    }
}

// MARK: - Refresh failure banner

/// Non-blocking notice shown when pull-to-refresh fails but cached data is still on screen.
final class RefreshBannerView: UIView {
    private let label = UILabel()
    private let iconView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setMessage(_ text: String?) {
        label.text = text
        isHidden = text == nil
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = AppTheme.Color.warningFill

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        iconView.tintColor = AppTheme.Color.warningInk
        iconView.setContentHuggingPriority(.required, for: .horizontal)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppTheme.Font.caption()
        label.textColor = AppTheme.Color.warningInk
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true

        addSubview(iconView)
        addSubview(label)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AppTheme.Spacing.md),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.topAnchor.constraint(equalTo: topAnchor, constant: AppTheme.Spacing.xs),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -AppTheme.Spacing.xs),
            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: AppTheme.Spacing.xs),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -AppTheme.Spacing.md)
        ])
    }
}
