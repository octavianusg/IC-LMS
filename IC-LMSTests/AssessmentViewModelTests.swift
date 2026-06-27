import Testing
import Foundation
@testable import IC_LMS

@MainActor
@Suite("AssessmentViewModel")
struct AssessmentViewModelTests {

    private let skill = PredefinedSkillLibrary.all[0]
    private let participant = Participant(name: "Aria")
    private let challengeID = UUID()

    private func makeCheckpoint() -> Checkpoint {
        Checkpoint(title: "Observe", skill: skill)!
    }

    private func makeViewModel(
        checkpoint: Checkpoint,
        cloudKit: MockCloudKitManager = MockCloudKitManager(),
        log: SpyLogManager = SpyLogManager()
    ) -> AssessmentViewModel {
        AssessmentViewModel(
            challengeID: challengeID,
            checkpoint: checkpoint,
            participant: participant,
            cloudKit: cloudKit,
            log: log
        )
    }

    @Test func loadAdoptsExistingAssessment() async {
        let checkpoint = makeCheckpoint()
        let existing = CheckpointAssessment(
            challengeID: challengeID,
            checkpointID: checkpoint.id,
            participantID: participant.id,
            skillID: skill.id,
            evidence: [Evidence(kind: .handwritingBlank)],
            finalRatingLevel: 2
        )
        let cloudKit = MockCloudKitManager(storedAssessments: [existing])
        let viewModel = makeViewModel(checkpoint: checkpoint, cloudKit: cloudKit)

        await viewModel.load()

        #expect(viewModel.assessment.id == existing.id)
        #expect(viewModel.orderedEvidence.count == 1)
        #expect(viewModel.finalRatingLevel == 2)
    }

    @Test func loadWithNoMatchKeepsFreshDraft() async {
        let checkpoint = makeCheckpoint()
        let viewModel = makeViewModel(checkpoint: checkpoint)

        await viewModel.load()

        #expect(viewModel.orderedEvidence.isEmpty)
        #expect(viewModel.finalRatingLevel == nil)
    }

    @Test func addPhotoNoteAppendsAndAutosaves() async {
        let cloudKit = MockCloudKitManager()
        let viewModel = makeViewModel(checkpoint: makeCheckpoint(), cloudKit: cloudKit)

        await viewModel.addPhotoNote(imageData: Data([0x1]), caption: "Sketching ideas")

        #expect(viewModel.orderedEvidence.count == 1)
        #expect(viewModel.orderedEvidence.first?.kind == .photoNote)
        #expect(cloudKit.storedAssessments.count == 1)
        #expect(cloudKit.saveCount == 1)
    }

    @Test func handwritingKindDependsOnPhotoPresence() async {
        let viewModel = makeViewModel(checkpoint: makeCheckpoint())

        await viewModel.addHandwriting(imageData: Data([0x2]), isAnnotation: false, caption: "")
        await viewModel.addHandwriting(imageData: Data([0x3]), isAnnotation: true, caption: "")

        let kinds = viewModel.orderedEvidence.map(\.kind)
        #expect(kinds == [.handwritingBlank, .handwritingAnnotation])
    }

    @Test func removeEvidenceDeletesAndAutosaves() async {
        let cloudKit = MockCloudKitManager()
        let viewModel = makeViewModel(checkpoint: makeCheckpoint(), cloudKit: cloudKit)
        await viewModel.addStudentUpload(imageData: Data([0x5]), caption: "Final piece")
        let evidenceID = viewModel.orderedEvidence[0].id

        await viewModel.removeEvidence(id: evidenceID)

        #expect(viewModel.orderedEvidence.isEmpty)
        #expect(cloudKit.saveCount == 2)
    }

    @Test func setFinalRatingWithinRangePersists() async {
        let cloudKit = MockCloudKitManager()
        let viewModel = makeViewModel(checkpoint: makeCheckpoint(), cloudKit: cloudKit)

        await viewModel.setFinalRating(level: skill.defaultAnchors.count - 1)

        #expect(viewModel.finalRatingLevel == skill.defaultAnchors.count - 1)
        #expect(cloudKit.storedAssessments.first?.finalRatingLevel == skill.defaultAnchors.count - 1)
    }

    @Test func setFinalRatingOutOfRangeValidatesAndDoesNotSave() async {
        let cloudKit = MockCloudKitManager()
        let viewModel = makeViewModel(checkpoint: makeCheckpoint(), cloudKit: cloudKit)

        await viewModel.setFinalRating(level: 99)

        #expect(viewModel.finalRatingLevel == nil)
        #expect(cloudKit.saveCount == 0)
        if case .validation = viewModel.currentError {} else {
            Issue.record("Expected validation error")
        }
    }

    @Test func saveFailureSurfacesErrorAndLogs() async {
        let cloudKit = MockCloudKitManager()
        cloudKit.errorToThrow = .persistenceFailed(reason: "offline")
        let log = SpyLogManager()
        let viewModel = makeViewModel(checkpoint: makeCheckpoint(), cloudKit: cloudKit, log: log)

        await viewModel.addPhotoNote(imageData: Data([0x6]), caption: "")

        #expect(viewModel.currentError == .persistenceFailed(reason: "offline"))
        #expect(log.errorCount == 1)
    }
}
