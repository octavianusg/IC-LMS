import Testing
import Foundation
@testable import IC_LMS

@MainActor
@Suite("ChallengeEditorViewModel")
struct ChallengeEditorViewModelTests {

    private func makeViewModel(
        challenge: Challenge = Challenge(title: "Test Challenge"),
        cloudKit: MockCloudKitManager = MockCloudKitManager(),
        log: SpyLogManager = SpyLogManager()
    ) -> ChallengeEditorViewModel {
        ChallengeEditorViewModel(challenge: challenge, cloudKit: cloudKit, log: log)
    }

    @Test func addContentInsertsIntoCorrectPhaseAndAutosaves() async {
        let cloudKit = MockCloudKitManager()
        let viewModel = makeViewModel(cloudKit: cloudKit)

        await viewModel.addContent(.lesson, title: "Intro Lesson", to: .investigate)

        let investigate = viewModel.challenge.phase(.investigate)
        #expect(investigate.items.count == 1)
        #expect(viewModel.challenge.phase(.engage).items.isEmpty)
        #expect(cloudKit.saveCount == 1)
    }

    @Test func addAssignmentInsertsAssignmentItem() async {
        let viewModel = makeViewModel()

        await viewModel.addAssignment(title: "Build a model", to: .act)

        let item = viewModel.challenge.phase(.act).items.first
        if case .assignment(let assignment)? = item {
            #expect(assignment.title == "Build a model")
        } else {
            Issue.record("Expected an assignment item")
        }
    }

    @Test func addCheckpointReferencesSingleSkillWithDefaultAnchors() async {
        let viewModel = makeViewModel()
        let skill = PredefinedSkillLibrary.all[0]

        await viewModel.addCheckpoint(title: "Observe creativity", skill: skill, to: .engage)

        let item = viewModel.challenge.phase(.engage).items.first
        if case .checkpoint(let checkpoint)? = item {
            #expect(checkpoint.skillID == skill.id)
            #expect(checkpoint.workingAnchors == skill.defaultAnchors)
        } else {
            Issue.record("Expected a checkpoint item")
        }
    }

    @Test func addCheckpointWithEmptyTitleValidates() async {
        let cloudKit = MockCloudKitManager()
        let viewModel = makeViewModel(cloudKit: cloudKit)

        await viewModel.addCheckpoint(title: "  ", skill: PredefinedSkillLibrary.all[0], to: .engage)

        #expect(viewModel.challenge.phase(.engage).items.isEmpty)
        #expect(cloudKit.saveCount == 0)
        if case .validation = viewModel.currentError {} else {
            Issue.record("Expected validation error")
        }
    }

    @Test func addContentEmptyTitleValidatesAndDoesNotSave() async {
        let cloudKit = MockCloudKitManager()
        let viewModel = makeViewModel(cloudKit: cloudKit)

        await viewModel.addContent(.resource, title: "", to: .act)

        #expect(viewModel.challenge.itemCount == 0)
        #expect(cloudKit.saveCount == 0)
        if case .validation = viewModel.currentError {} else {
            Issue.record("Expected validation error")
        }
    }

    @Test func saveFailureSurfacesErrorAndLogs() async {
        let cloudKit = MockCloudKitManager()
        cloudKit.errorToThrow = .persistenceFailed(reason: "boom")
        let log = SpyLogManager()
        let viewModel = makeViewModel(cloudKit: cloudKit, log: log)

        await viewModel.addAssignment(title: "Task", to: .act)

        #expect(viewModel.currentError == .persistenceFailed(reason: "boom"))
        #expect(log.errorCount == 1)
    }

    @Test func removeItemDeletesFromPhaseAndAutosaves() async {
        let cloudKit = MockCloudKitManager()
        let viewModel = makeViewModel(cloudKit: cloudKit)
        await viewModel.addContent(.material, title: "Handout", to: .investigate)
        let itemID = viewModel.challenge.phase(.investigate).items[0].id

        await viewModel.removeItem(id: itemID, from: .investigate)

        #expect(viewModel.challenge.phase(.investigate).items.isEmpty)
        #expect(cloudKit.saveCount == 2)
    }

    @Test func addParticipantAppendsToRosterAndAutosaves() async {
        let cloudKit = MockCloudKitManager()
        let viewModel = makeViewModel(cloudKit: cloudKit)

        await viewModel.addParticipant(name: "  Bima  ")

        #expect(viewModel.challenge.participants.map(\.name) == ["Bima"])
        #expect(cloudKit.saveCount == 1)
    }

    @Test func addParticipantEmptyNameValidates() async {
        let cloudKit = MockCloudKitManager()
        let viewModel = makeViewModel(cloudKit: cloudKit)

        await viewModel.addParticipant(name: "   ")

        #expect(viewModel.challenge.participants.isEmpty)
        #expect(cloudKit.saveCount == 0)
        if case .validation = viewModel.currentError {} else {
            Issue.record("Expected validation error")
        }
    }

    @Test func concurrentEditsSerializeWithoutLosingUpdates() async {
        let cloudKit = MockCloudKitManager()
        let viewModel = makeViewModel(cloudKit: cloudKit)

        async let first: Void = viewModel.addContent(.lesson, title: "A", to: .engage)
        async let second: Void = viewModel.addAssignment(title: "B", to: .act)
        _ = await (first, second)

        #expect(viewModel.challenge.phase(.engage).items.count == 1)
        #expect(viewModel.challenge.phase(.act).items.count == 1)

        let stored = cloudKit.storedChallenges.first
        #expect(stored?.phase(.engage).items.count == 1)
        #expect(stored?.phase(.act).items.count == 1)
        #expect(viewModel.isSaving == false)
    }

    @Test func removeParticipantDeletesFromRoster() async {
        let cloudKit = MockCloudKitManager()
        let viewModel = makeViewModel(cloudKit: cloudKit)
        await viewModel.addParticipant(name: "Citra")
        let id = viewModel.challenge.participants[0].id

        await viewModel.removeParticipant(id: id)

        #expect(viewModel.challenge.participants.isEmpty)
    }
}
