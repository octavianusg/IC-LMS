import Foundation

struct Participant: Identifiable, Codable, Equatable, Hashable, Sendable {
    var id: UUID
    var name: String

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}
