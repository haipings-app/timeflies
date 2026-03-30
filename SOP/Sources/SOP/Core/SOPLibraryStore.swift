import Foundation

@MainActor
final class SOPLibraryStore: ObservableObject {
    @Published private(set) var savedResources: [SOPSavedResource] = []
    @Published var isDownloading = false
    @Published var downloadMessage = ""

    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        loadLibrary()
    }

    func resources(for category: DeviceCategory) -> [SOPSavedResource] {
        savedResources
            .filter { $0.category == category }
            .sorted { $0.savedAt > $1.savedAt }
    }

    func localURL(for resource: SOPSavedResource) -> URL {
        libraryDirectoryURL
            .appendingPathComponent(resource.category.storageFolderName, isDirectory: true)
            .appendingPathComponent(resource.localFilename)
    }

    func saveResource(from candidate: ScannedResourceCandidate, category: DeviceCategory) async {
        guard candidate.isSupported else {
            downloadMessage = "This QR code does not point to a supported file."
            return
        }

        isDownloading = true
        downloadMessage = "Downloading \(candidate.kind.title) file..."

        do {
            let (temporaryURL, _) = try await URLSession.shared.download(from: candidate.url)
            let destinationFolder = libraryDirectoryURL.appendingPathComponent(category.storageFolderName, isDirectory: true)
            try ensureDirectoryExists(at: destinationFolder)

            let safeFilename = uniqueFilename(
                basedOn: candidate.filename,
                in: destinationFolder
            )
            let destinationURL = destinationFolder.appendingPathComponent(safeFilename)

            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.moveItem(at: temporaryURL, to: destinationURL)

            let resource = SOPSavedResource(
                title: candidate.suggestedTitle,
                originalURL: candidate.url,
                localFilename: safeFilename,
                kind: candidate.kind,
                category: category
            )

            savedResources.insert(resource, at: 0)
            try persistLibrary()
            downloadMessage = "Saved to \(category.title)."
        } catch {
            downloadMessage = "Download failed. Please check the link and try again."
        }

        isDownloading = false
    }

    private func loadLibrary() {
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601

        do {
            let data = try Data(contentsOf: indexURL)
            savedResources = try decoder.decode([SOPSavedResource].self, from: data)
        } catch {
            savedResources = []
        }
    }

    private func persistLibrary() throws {
        try ensureDirectoryExists(at: libraryDirectoryURL)
        let data = try encoder.encode(savedResources)
        try data.write(to: indexURL, options: .atomic)
    }

    private func ensureDirectoryExists(at url: URL) throws {
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
    }

    private func uniqueFilename(basedOn original: String, in folder: URL) -> String {
        let source = original.isEmpty ? "resource" : original
        let base = URL(fileURLWithPath: source).deletingPathExtension().lastPathComponent
        let ext = URL(fileURLWithPath: source).pathExtension

        var candidate = source
        var index = 1

        while fileManager.fileExists(atPath: folder.appendingPathComponent(candidate).path) {
            let suffix = "-\(index)"
            if ext.isEmpty {
                candidate = "\(base)\(suffix)"
            } else {
                candidate = "\(base)\(suffix).\(ext)"
            }
            index += 1
        }

        return candidate
    }

    private var libraryDirectoryURL: URL {
        let root = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        return root.appendingPathComponent("SOPLibrary", isDirectory: true)
    }

    private var indexURL: URL {
        libraryDirectoryURL.appendingPathComponent("library.json")
    }
}
