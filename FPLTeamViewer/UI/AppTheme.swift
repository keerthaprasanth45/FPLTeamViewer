import UIKit

/// Single source of truth for colours, type, and spacing.
/// Screens and storyboard cells should read from here instead of hard-coding values,
/// so a visual change stays consistent across Teams, Squad, and empty/error states.
enum AppTheme {

    // MARK: - Colours

    /// Named colours live in `Assets.xcassets` so they adapt to Light/Dark Mode.
    /// Fallbacks exist so unit tests and Interface Builder still render if an asset is missing.
    enum Color {
        /// Pitch green — primary brand colour for tint, badges, and accents.
        static let pitch = named("PitchGreen", fallback: UIColor(red: 0.05, green: 0.45, blue: 0.27, alpha: 1))
        /// Soft green wash behind badges and selected chrome.
        static let pitchMuted = named("PitchGreenMuted", fallback: UIColor(red: 0.90, green: 0.96, blue: 0.93, alpha: 1))
        /// Screen background; slightly cooler than pure system background so cards stand out.
        static let canvas = named("Canvas", fallback: UIColor(red: 0.95, green: 0.96, blue: 0.95, alpha: 1))
        /// Raised card / cell fill.
        static let card = named("Card", fallback: .secondarySystemGroupedBackground)
        /// Primary readable text.
        static let ink = named("Ink", fallback: .label)
        /// Supporting text (short names, captions).
        static let secondaryInk = named("SecondaryInk", fallback: .secondaryLabel)
        /// FPL points emphasis.
        static let gold = named("Gold", fallback: UIColor(red: 0.79, green: 0.59, blue: 0.16, alpha: 1))
        /// Refresh-failure banner.
        static let warningFill = named("WarningFill", fallback: UIColor.systemOrange.withAlphaComponent(0.18))
        static let warningInk = named("WarningInk", fallback: UIColor.systemOrange)

        // Position chips use distinct hues so a squad list is scannable at a glance.
        static let goalkeeper = named("Goalkeeper", fallback: UIColor(red: 0.18, green: 0.49, blue: 0.20, alpha: 1))
        static let defender = named("Defender", fallback: UIColor(red: 0.08, green: 0.40, blue: 0.75, alpha: 1))
        static let midfielder = named("Midfielder", fallback: UIColor(red: 0.42, green: 0.11, blue: 0.60, alpha: 1))
        static let forward = named("Forward", fallback: UIColor(red: 0.78, green: 0.16, blue: 0.16, alpha: 1))

        /// Maps FPL position short codes (GKP/DEF/MID/FWD) onto chip colours.
        static func accent(for position: Position) -> UIColor {
            switch position.shortName {
            case "GKP": return goalkeeper
            case "DEF": return defender
            case "MID": return midfielder
            case "FWD": return forward
            default: return pitch
            }
        }

        private static func named(_ name: String, fallback: UIColor) -> UIColor {
            UIColor(named: name) ?? fallback
        }
    }

    // MARK: - Typography

    /// Dynamic Type fonts with explicit weights. Prefer these over raw `UIFont.systemFont`
    /// so titles, body copy, and chips stay aligned if we change the type ramp later.
    enum Font {
        static func largeTitle() -> UIFont { scaled(.largeTitle, weight: .bold) }
        static func screenTitle() -> UIFont { scaled(.title2, weight: .bold) }
        static func headline() -> UIFont { scaled(.headline, weight: .semibold) }
        static func body() -> UIFont { scaled(.body, weight: .regular) }
        static func subhead() -> UIFont { scaled(.subheadline, weight: .regular) }
        static func caption() -> UIFont { scaled(.caption1, weight: .medium) }
        static func badge() -> UIFont { scaled(.caption1, weight: .bold) }
        static func points() -> UIFont { scaled(.title2, weight: .bold) }
        static func button() -> UIFont { scaled(.headline, weight: .semibold) }

        private static func scaled(_ style: UIFont.TextStyle, weight: UIFont.Weight) -> UIFont {
            let base = UIFont.preferredFont(forTextStyle: style)
            let font = UIFont.systemFont(ofSize: base.pointSize, weight: weight)
            return UIFontMetrics(forTextStyle: style).scaledFont(for: font)
        }
    }

    // MARK: - Layout tokens

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
    }

    enum Radius {
        static let badge: CGFloat = 12
        static let chip: CGFloat = 8
        static let pill: CGFloat = 14
        static let points: CGFloat = 16
    }

    // MARK: - Global appearance

    /// Applies navigation / control tint once at launch so every screen inherits the pitch-green brand.
    static func applyGlobalAppearance() {
        let accent = Color.pitch

        UIView.appearance().tintColor = accent

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithDefaultBackground()
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: Color.ink,
            .font: Font.largeTitle()
        ]
        navAppearance.titleTextAttributes = [
            .foregroundColor: Color.ink,
            .font: Font.headline()
        ]

        let navigationBar = UINavigationBar.appearance()
        navigationBar.tintColor = accent
        navigationBar.standardAppearance = navAppearance
        navigationBar.scrollEdgeAppearance = navAppearance
        navigationBar.compactAppearance = navAppearance
    }
}

// MARK: - View helpers

extension UIView {
    /// Applies a continuous corner curve used by badges, chips, and points pills.
    func applyThemeCornerRadius(_ radius: CGFloat) {
        layer.cornerRadius = radius
        layer.cornerCurve = .continuous
        clipsToBounds = true
    }
}
