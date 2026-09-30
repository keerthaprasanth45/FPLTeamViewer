import Foundation

protocol BootstrapCache {
    func load() throws -> Data?
    func save(_ data: Data) throws
}

/// Persists the last successful bootstrap JSON so a later offline launch can still render teams.
final class FileBootstrapCache: BootstrapCache {
    private let fileURL: URL

    init(fileURL: URL? = nil) {
        if let fileURL {
            self.fileURL = fileURL
        } else {
            let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                ?? FileManager.default.temporaryDirectory
            let folder = directory.appendingPathComponent("FPLTeamViewer", isDirectory: true)
            self.fileURL = folder.appendingPathComponent("bootstrap-static.json")
        }
    }

    func load() throws -> Data? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        return try Data(contentsOf: fileURL)
    }

    func save(_ data: Data) throws {
        let folder = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try data.write(to: fileURL, options: .atomic)
    }
}
