import Foundation

enum DeviceCategory: String, CaseIterable, Codable, Identifiable {
    case labEquipment
    case printer
    case projector
    case computer
    case network
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .labEquipment: "Lab Equipment"
        case .printer: "Printer"
        case .projector: "Projector"
        case .computer: "Computer"
        case .network: "Network Device"
        case .other: "Other"
        }
    }

    var storageFolderName: String {
        rawValue
    }
}

enum SOPResourceKind: String, Codable {
    case pdf
    case text
    case word
    case video
    case unsupported

    var title: String {
        switch self {
        case .pdf: "PDF"
        case .text: "Text"
        case .word: "Word"
        case .video: "Video"
        case .unsupported: "Unsupported"
        }
    }

    var supportsPreview: Bool {
        self != .unsupported
    }
}

struct SOPSavedResource: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var originalURL: URL
    var localFilename: String
    var kind: SOPResourceKind
    var category: DeviceCategory
    var savedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        originalURL: URL,
        localFilename: String,
        kind: SOPResourceKind,
        category: DeviceCategory,
        savedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.originalURL = originalURL
        self.localFilename = localFilename
        self.kind = kind
        self.category = category
        self.savedAt = savedAt
    }
}

struct ScannedResourceCandidate {
    let url: URL
    let kind: SOPResourceKind

    var suggestedTitle: String {
        let name = url.deletingPathExtension().lastPathComponent
        return name.isEmpty ? url.absoluteString : name
    }

    var filename: String {
        let lastPath = url.lastPathComponent
        return lastPath.isEmpty ? "resource" : lastPath
    }

    var isSupported: Bool {
        kind != .unsupported
    }
}
