import Foundation

enum PhaseKind: String, Codable, CaseIterable, Identifiable, Sendable {
    case engage
    case investigate
    case act

    var id: String { rawValue }

    var title: String {
        switch self {
        case .engage: return "Engage"
        case .investigate: return "Investigate"
        case .act: return "Act"
        }
    }

    var subtitle: String {
        switch self {
        case .engage: return "Spark curiosity and frame the big idea."
        case .investigate: return "Explore, research, and build understanding."
        case .act: return "Create, apply, and share the solution."
        }
    }
}

struct ChallengePhase: Identifiable, Codable, Equatable, Sendable {
    var kind: PhaseKind
    var items: [PhaseItem]

    var id: PhaseKind { kind }

    init(kind: PhaseKind, items: [PhaseItem] = []) {
        self.kind = kind
        self.items = items
    }
}
