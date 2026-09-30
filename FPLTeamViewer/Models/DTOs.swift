import Foundation

// MARK: - API DTOs
// Only the fields the app needs are decoded; extra JSON keys are ignored by Codable.

struct BootstrapDTO: Decodable, Equatable {
    let teams: [TeamDTO]
    let elementTypes: [ElementTypeDTO]
    let elements: [ElementDTO]

    enum CodingKeys: String, CodingKey {
        case teams
        case elementTypes = "element_types"
        case elements
    }
}

struct TeamDTO: Decodable, Equatable {
    let id: Int
    let name: String
    let shortName: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case shortName = "short_name"
    }
}

struct ElementTypeDTO: Decodable, Equatable {
    let id: Int
    let singularName: String
    let pluralName: String
    let singularNameShort: String

    enum CodingKeys: String, CodingKey {
        case id
        case singularName = "singular_name"
        case pluralName = "plural_name"
        case singularNameShort = "singular_name_short"
    }
}

struct ElementDTO: Decodable, Equatable {
    let id: Int
    let firstName: String
    let secondName: String
    let webName: String
    let team: Int
    let elementType: Int
    let nowCost: Int
    let totalPoints: Int

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case secondName = "second_name"
        case webName = "web_name"
        case team
        case elementType = "element_type"
        case nowCost = "now_cost"
        case totalPoints = "total_points"
    }
}
