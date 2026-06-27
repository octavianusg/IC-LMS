import Foundation

struct Assignment: Identifiable, Codable, Equatable, Sendable {
    var id: UUID
    var title: String
    var instructions: String

    init(id: UUID = UUID(), title: String, instructions: String = "") {
        self.id = id
        self.title = title
        self.instructions = instructions
    }
}
