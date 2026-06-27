import Foundation

enum PredefinedSkillLibrary {
    static let all: [Skill] = [
        Skill(
            id: "creativity",
            name: "Creativity",
            summary: "Generates original ideas and approaches problems in inventive ways.",
            defaultAnchors: [
                "Reproduces existing ideas with little variation.",
                "Adapts known ideas to the task with some originality.",
                "Combines ideas in unexpected, purposeful ways.",
                "Produces genuinely novel solutions and inspires others."
            ]
        ),
        Skill(
            id: "critical-thinking",
            name: "Critical Thinking",
            summary: "Analyzes information, weighs evidence, and reasons toward sound conclusions.",
            defaultAnchors: [
                "Accepts claims without questioning.",
                "Identifies some assumptions and asks clarifying questions.",
                "Evaluates evidence and distinguishes strong from weak reasoning.",
                "Synthesizes multiple sources into a well-justified judgment."
            ]
        ),
        Skill(
            id: "collaboration",
            name: "Collaboration",
            summary: "Works effectively with others toward a shared goal.",
            defaultAnchors: [
                "Works in isolation and rarely contributes to the group.",
                "Participates when prompted and shares some responsibility.",
                "Actively contributes and supports teammates' ideas.",
                "Coordinates the group and elevates others' contributions."
            ]
        ),
        Skill(
            id: "communication",
            name: "Communication",
            summary: "Expresses ideas clearly and listens to understand.",
            defaultAnchors: [
                "Ideas are unclear or hard to follow.",
                "Communicates the main idea with some clarity.",
                "Communicates clearly and adapts to the audience.",
                "Communicates persuasively and listens to refine ideas."
            ]
        ),
        Skill(
            id: "resilience",
            name: "Resilience",
            summary: "Persists through difficulty and learns from setbacks.",
            defaultAnchors: [
                "Gives up when the task becomes difficult.",
                "Continues with encouragement after setbacks.",
                "Persists independently and adjusts the approach.",
                "Embraces challenge and turns setbacks into learning."
            ]
        )
    ]

    static func skill(withID id: String) -> Skill? {
        all.first { $0.id == id }
    }
}
