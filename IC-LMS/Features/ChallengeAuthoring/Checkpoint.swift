import Foundation

struct Checkpoint: Identifiable, Codable, Equatable, Hashable, Sendable {
    var id: UUID
    var title: String
    var skillID: String
    var workingAnchors: [String]

    init(id: UUID = UUID(), title: String, skillID: String, workingAnchors: [String]) {
        self.id = id
        self.title = title
        self.skillID = skillID
        self.workingAnchors = workingAnchors
    }

    init?(id: UUID = UUID(), title: String, skill: Skill) {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        self.init(id: id, title: title, skillID: skill.id, workingAnchors: skill.defaultAnchors)
    }
}
