import Foundation

enum ContentKind: String, Codable, CaseIterable, Identifiable, Sendable {
    case lesson
    case resource
    case material

    var id: String { rawValue }

    var label: String {
        switch self {
        case .lesson: return "Lesson"
        case .resource: return "Resource"
        case .material: return "Material"
        }
    }
}

struct ContentItem: Identifiable, Codable, Equatable, Sendable {
    var id: UUID
    var kind: ContentKind
    var title: String
    var body: String

    init(id: UUID = UUID(), kind: ContentKind, title: String, body: String = "") {
        self.id = id
        self.kind = kind
        self.title = title
        self.body = body
    }
}
