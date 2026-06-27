import Foundation

enum SampleData {
    static func challenges() -> [Challenge] {
        [waterChallenge(), marketChallenge()]
    }

    static func assessments(for challenges: [Challenge]) -> [CheckpointAssessment] {
        guard let challenge = challenges.first,
              let participant = challenge.participants.first,
              let checkpoint = challenge.checkpoints(in: .investigate).first else {
            return []
        }
        return [
            CheckpointAssessment(
                challengeID: challenge.id,
                checkpointID: checkpoint.id,
                participantID: participant.id,
                skillID: checkpoint.skillID,
                evidence: [
                    Evidence(kind: .handwritingBlank, caption: "Strong initial questions about runoff."),
                    Evidence(kind: .photoNote, caption: "Built a filtration prototype with peers.")
                ],
                finalRatingLevel: 2
            )
        ]
    }

    private static func waterChallenge() -> Challenge {
        let critical = PredefinedSkillLibrary.skill(withID: "critical-thinking")!
        let collaboration = PredefinedSkillLibrary.skill(withID: "collaboration")!
        return Challenge(
            title: "Clean Water for Our School",
            summary: "Investigate local water quality and design a filtration solution.",
            phases: [
                ChallengePhase(kind: .engage, items: [
                    .content(ContentItem(kind: .lesson, title: "Why water matters", body: "Open with the big idea: access to clean water.")),
                    .checkpoint(Checkpoint(title: "Notice curiosity", skill: critical)!)
                ]),
                ChallengePhase(kind: .investigate, items: [
                    .content(ContentItem(kind: .resource, title: "Water testing guide", body: "How to sample and measure turbidity.")),
                    .assignment(Assignment(title: "Test three water sources", instructions: "Record turbidity and pH for each.")),
                    .checkpoint(Checkpoint(title: "Assess investigation", skill: critical)!)
                ]),
                ChallengePhase(kind: .act, items: [
                    .assignment(Assignment(title: "Build a filter prototype", instructions: "Use available materials to improve clarity.")),
                    .checkpoint(Checkpoint(title: "Assess teamwork", skill: collaboration)!)
                ])
            ],
            participants: [
                Participant(name: "Aria"),
                Participant(name: "Bima"),
                Participant(name: "Citra")
            ],
            ownerName: "Ms. Dewi"
        )
    }

    private static func marketChallenge() -> Challenge {
        let creativity = PredefinedSkillLibrary.skill(withID: "creativity")!
        return Challenge(
            title: "Design a Community Market",
            summary: "Reimagine a local market stall that serves the neighborhood.",
            phases: [
                ChallengePhase(kind: .engage, items: [
                    .content(ContentItem(kind: .lesson, title: "What makes a market thrive?"))
                ]),
                ChallengePhase(kind: .investigate, items: [
                    .assignment(Assignment(title: "Interview a vendor"))
                ]),
                ChallengePhase(kind: .act, items: [
                    .assignment(Assignment(title: "Pitch your stall design")),
                    .checkpoint(Checkpoint(title: "Assess creativity", skill: creativity)!)
                ])
            ],
            participants: [
                Participant(name: "Eka"),
                Participant(name: "Fajar")
            ],
            ownerName: "Mr. Gunawan"
        )
    }
}
