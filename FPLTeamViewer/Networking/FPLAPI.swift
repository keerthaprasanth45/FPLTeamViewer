import Foundation

enum FPLAPI {
    static let bootstrapStatic = URL(string: "https://fantasy.premierleague.com/api/bootstrap-static/")!
}

enum FPLError: Error, Equatable {
    case invalidResponse
    case decodingFailed
    case emptyCache
}
