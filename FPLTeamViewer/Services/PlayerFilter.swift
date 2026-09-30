import Foundation

/// Case-insensitive search across name, web name, and position — used as the user types.
enum PlayerFilter {
    static func filter(players: [Player], query: String) -> [Player] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return players }

        return players.filter { player in
            player.name.localizedStandardContains(trimmed)
                || player.webName.localizedStandardContains(trimmed)
                || player.position.name.localizedStandardContains(trimmed)
                || player.position.shortName.localizedStandardContains(trimmed)
        }
    }
}
