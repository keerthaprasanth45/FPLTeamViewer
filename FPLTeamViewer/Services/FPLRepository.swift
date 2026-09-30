import Foundation

protocol FPLRepository {
    func loadCached() throws -> Bootstrap?
    func fetchRemote() async throws -> Bootstrap
}

/// Fetches bootstrap-static JSON, maps it to domain models, and writes the raw payload to disk.
final class DefaultFPLRepository: FPLRepository {

    // MARK: - Dependencies

    private let client: HTTPClient
    private let cache: BootstrapCache
    private let decoder: JSONDecoder
    private let endpoint: URL

    // MARK: - Init

    init(
        client: HTTPClient,
        cache: BootstrapCache,
        decoder: JSONDecoder = JSONDecoder(),
        endpoint: URL = FPLAPI.bootstrapStatic
    ) {
        self.client = client
        self.cache = cache
        self.decoder = decoder
        self.endpoint = endpoint
    }

    // MARK: - FPLRepository

    func loadCached() throws -> Bootstrap? {
        guard let data = try cache.load() else { return nil }
        return try decodeBootstrap(from: data)
    }

    func fetchRemote() async throws -> Bootstrap {
        let (data, response) = try await client.data(from: endpoint)
        guard let http = response as? HTTPURLResponse else {
            throw FPLError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw FPLError.invalidResponse
        }

        let bootstrap = try decodeBootstrap(from: data)
        // Cache writes are best-effort: a full disk should not hide a successful fetch.
        try? cache.save(data)
        return bootstrap
    }

    // MARK: - Decoding

    private func decodeBootstrap(from data: Data) throws -> Bootstrap {
        do {
            let dto = try decoder.decode(BootstrapDTO.self, from: data)
            return BootstrapMapper.map(dto)
        } catch is DecodingError {
            throw FPLError.decodingFailed
        } catch {
            throw error
        }
    }
}
