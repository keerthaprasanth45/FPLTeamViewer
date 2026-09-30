import Foundation

/// UI-facing load states for a screen that can show cached data during a refresh.
enum ContentLoadState<Value: Equatable>: Equatable {
    case loading
    case loaded(Value)
    case failed(String)
    case refreshing(Value)
    case refreshFailed(Value, String)

    // MARK: - Queries

    var value: Value? {
        switch self {
        case .loading, .failed:
            return nil
        case .loaded(let value), .refreshing(let value), .refreshFailed(let value, _):
            return value
        }
    }

    var isRefreshing: Bool {
        if case .refreshing = self { return true }
        return false
    }

    var showsInitialLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var failureMessage: String? {
        switch self {
        case .failed(let message):
            return message
        case .refreshFailed(_, let message):
            return message
        case .loading, .loaded, .refreshing:
            return nil
        }
    }
}

// MARK: - User-facing error copy

enum LoadErrorPresenter {
    /// Turns transport / domain errors into copy the screens can show without leaking NSURLError codes.
    static func message(for error: Error) -> String {
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
                return "You appear to be offline. Connect to the internet and try again."
            case NSURLErrorTimedOut:
                return "The request timed out. Please try again."
            default:
                break
            }
        }

        if let fplError = error as? FPLError {
            switch fplError {
            case .invalidResponse:
                return "The server returned an unexpected response."
            case .decodingFailed:
                return "The data could not be read. Please try again."
            case .emptyCache:
                return "No saved data is available yet."
            }
        }

        return "Something went wrong. Please try again."
    }
}
