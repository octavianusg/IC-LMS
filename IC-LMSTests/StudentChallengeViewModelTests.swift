import Testing
import Foundation
@testable import IC_LMS

@MainActor
@Suite("StudentChallengeViewModel")
struct StudentChallengeViewModelTests {

    private func challengeWithAssignment() -> (Challenge, UUID) {
        let assignment = Assignment(title: "Interview a vendor")
        let challenge = Challenge(
            title: "Market",
            phases: [
                ChallengePhase(kind: .engage, items: [
                    .content(ContentItem(kind: .lesson, title: "Intro")),
                    .checkpoint(Checkpoint(title: "Hidden", skill: PredefinedSkillLibrary.all[0])!)
                ]),
                ChallengePhase(kind: .investigate, items: [.assignment(assignment)]),
                ChallengePhase(kind: .act, items: [])
            ]
        )
        return (challenge, assignment.id)
    }

    private func makeViewModel(
        challenge: Challenge,
        cloudKit: MockCloudKitManager = MockCloudKitManager(),
        log: SpyLogManager = SpyLogManager()
    ) -> StudentChallengeViewModel {
        StudentChallengeViewModel(challenge: challenge, cloudKit: cloudKit, log: log)
    }

    @Test func visiblePhasesHideCheckpoints() {
        let (challenge, _) = challengeWithAssignment()
        let viewModel = makeViewModel(challenge: challenge)

        let engageItems = viewModel.visiblePhases.first { $0.kind == .engage }?.items ?? []
        #expect(engageItems.count == 1)
        #expect(engageItems.allSatisfy { $0.checkpoint == nil })
    }

    @Test func submitWithoutNameValidates() async {
        let (challenge, assignmentID) = challengeWithAssignment()
        let cloudKit = MockCloudKitManager()
        let viewModel = makeViewModel(challenge: challenge, cloudKit: cloudKit)

        await viewModel.submit(assignmentID: assignmentID, note: "Done", imageData: nil)

        #expect(viewModel.submissions.isEmpty)
        if case .validation = viewModel.currentError {} else {
            Issue.record("Expected validation error")
        }
    }

    @Test func submitPersistsAndMarksSubmitted() async {
        let (challenge, assignmentID) = challengeWithAssignment()
        let cloudKit = MockCloudKitManager()
        let viewModel = makeViewModel(challenge: challenge, cloudKit: cloudKit)
        viewModel.studentName = "  Aria  "

        await viewModel.submit(assignmentID: assignmentID, note: "My interview notes", imageData: nil)

        #expect(viewModel.submissions.count == 1)
        #expect(viewModel.hasSubmitted(assignmentID: assignmentID))
        #expect(viewModel.submissions.first?.studentName == "Aria")
    }

    @Test func loadFetchesOnlyThisChallengesSubmissions() async {
        let (challenge, assignmentID) = challengeWithAssignment()
        let mine = Submission(challengeID: challenge.id, assignmentID: assignmentID, studentName: "Aria", note: "x")
        let other = Submission(challengeID: UUID(), assignmentID: UUID(), studentName: "Bima", note: "y")
        let cloudKit = MockCloudKitManager()
        try? await cloudKit.save(mine)
        try? await cloudKit.save(other)
        let viewModel = makeViewModel(challenge: challenge, cloudKit: cloudKit)

        await viewModel.load()

        #expect(viewModel.submissions.count == 1)
        #expect(viewModel.submissions.first?.id == mine.id)
    }
}
