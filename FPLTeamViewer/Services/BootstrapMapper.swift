import Foundation

/// Turns FPL API DTOs into UI models: player counts, position grouping, and squad sort order.
enum BootstrapMapper {

    // MARK: - Bootstrap

    static func map(_ dto: BootstrapDTO) -> Bootstrap {
        let positionsByID = Dictionary(
            uniqueKeysWithValues: dto.elementTypes.enumerated().map { index, type in
                (
                    type.id,
                    Position(
                        id: type.id,
                        name: type.singularName,
                        pluralName: type.pluralName,
                        shortName: type.singularNameShort,
                        sortOrder: index
                    )
                )
            }
        )

        let players: [Player] = dto.elements.compactMap { element in
            guard let position = positionsByID[element.elementType] else { return nil }
            return Player(
                id: element.id,
                name: displayName(firstName: element.firstName, secondName: element.secondName, webName: element.webName),
                webName: element.webName,
                teamID: element.team,
                position: position,
                nowCost: element.nowCost,
                totalPoints: element.totalPoints
            )
        }

        let playerCounts = Dictionary(grouping: players, by: \.teamID).mapValues(\.count)

        let teams = dto.teams
            .map { team in
                Team(
                    id: team.id,
                    name: team.name,
                    shortName: team.shortName,
                    playerCount: playerCounts[team.id, default: 0]
                )
            }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }

        return Bootstrap(teams: teams, players: players)
    }

    // MARK: - Squad

    static func squadSections(from players: [Player]) -> [SquadSection] {
        let grouped = Dictionary(grouping: players, by: \.position)
        return grouped.keys.sorted().compactMap { position in
            let ordered = (grouped[position] ?? []).sorted(by: playerSort)
            guard !ordered.isEmpty else { return nil }
            return SquadSection(position: position, players: ordered)
        }
    }

    static func playerSort(_ lhs: Player, _ rhs: Player) -> Bool {
        if lhs.totalPoints != rhs.totalPoints {
            return lhs.totalPoints > rhs.totalPoints
        }
        return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
    }

    // MARK: - Names

    private static func displayName(firstName: String, secondName: String, webName: String) -> String {
        let fullName = [firstName, secondName]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        return fullName.isEmpty ? webName : fullName
    }
}
