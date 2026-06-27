import Foundation

enum EvidenceKind: String, Codable, Sendable {
    case photoNote
    case handwritingBlank
    case handwritingAnnotation
    case studentUpload

    var label: String {
        switch self {
        case .photoNote: return "Photo & note"
        case .handwritingBlank: return "Handwriting"
        case .handwritingAnnotation: return "Annotated photo"
        case .studentUpload: return "Student work"
        }
    }

    var systemImage: String {
        switch self {
        case .photoNote: return "camera"
        case .handwritingBlank: return "pencil.and.scribble"
        case .handwritingAnnotation: return "photo.badge.plus"
        case .studentUpload: return "tray.and.arrow.up"
        }
    }

    var hasImagePayload: Bool {
        self == .photoNote || self == .handwritingAnnotation || self == .studentUpload
    }
}

struct Evidence: Identifiable, Codable, Equatable, Sendable {
    var id: UUID
    var kind: EvidenceKind
    var caption: String
    var createdAt: Date
    var imageData: Data?

    init(
        id: UUID = UUID(),
        kind: EvidenceKind,
        caption: String = "",
        createdAt: Date = Date(),
        imageData: Data? = nil
    ) {
        self.id = id
        self.kind = kind
        self.caption = caption
        self.createdAt = createdAt
        self.imageData = imageData
    }
}
