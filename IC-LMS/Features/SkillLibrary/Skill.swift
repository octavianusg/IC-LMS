import Foundation

struct Skill: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let summary: String
    let defaultAnchors: [String]
}
