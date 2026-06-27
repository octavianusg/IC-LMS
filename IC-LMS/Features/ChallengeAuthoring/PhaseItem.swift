import Foundation

enum PhaseItem: Identifiable, Codable, Equatable, Sendable {
    case content(ContentItem)
    case assignment(Assignment)
    case checkpoint(Checkpoint)

    var id: UUID {
        switch self {
        case .content(let item): return item.id
        case .assignment(let item): return item.id
        case .checkpoint(let item): return item.id
        }
    }

    var title: String {
        switch self {
        case .content(let item): return item.title
        case .assignment(let item): return item.title
        case .checkpoint(let item): return item.title
        }
    }

    var typeLabel: String {
        switch self {
        case .content(let item): return item.kind.label
        case .assignment: return "Assignment"
        case .checkpoint: return "Checkpoint"
        }
    }

    var systemImage: String {
        switch self {
        case .content: return "doc.text"
        case .assignment: return "checklist"
        case .checkpoint: return "target"
        }
    }
}
