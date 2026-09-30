import Foundation

// MARK: - Domain models
// UI-facing types produced by BootstrapMapper. Keep these independent of the API JSON shape.

struct Bootstrap: Equatable {
    let teams: [Team]
    let players: [Player]

    func players(forTeamID teamID: Int) -> [Player] {
        players.filter { $0.teamID == teamID }
    }
}

struct Team: Equatable, Hashable {
    let id: Int
    let name: String
    let shortName: String
    let playerCount: Int
}

struct Player: Equatable, Hashable {
    let id: Int
    let name: String
    let webName: String
    let teamID: Int
    let position: Position
    let nowCost: Int
    let totalPoints: Int

    var formattedPrice: String {
        FPLFormatting.price(fromTenthsOfMillions: nowCost)
    }
}

struct Position: Equatable, Hashable, Comparable {
    let id: Int
    let name: String
    let pluralName: String
    let shortName: String
    let sortOrder: Int

    static func < (lhs: Position, rhs: Position) -> Bool {
        if lhs.sortOrder != rhs.sortOrder {
            return lhs.sortOrder < rhs.sortOrder
        }
        return lhs.id < rhs.id
    }
}

struct SquadSection: Equatable, Hashable {
    let position: Position
    let players: [Player]
}

// MARK: - Formatting

enum FPLFormatting {
    /// FPL stores `now_cost` in tenths of millions (55 → £5.5m).
    static func price(fromTenthsOfMillions value: Int) -> String {
        let millions = Double(value) / 10.0
        return String(format: "£%.1fm", millions)
    }
}
