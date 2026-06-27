import Foundation
import Observation

@MainActor
@Observable
final class AssessmentViewModel {
    private(set) var assessment: CheckpointAssessment
    private(set) var isLoading = false
    private(set) var isSaving = false
    var currentError: AppError?

    let skill: Skill
    let participant: Participant

    private let checkpointAnchors: [String]
    private let cloudKit: CloudKitManaging
    private let log: LogManaging

    init(
        challengeID: UUID,
        checkpoint: Checkpoint,
        participant: Participant,
        cloudKit: CloudKitManaging,
        log: LogManaging
    ) {
        self.participant = participant
        self.skill = PredefinedSkillLibrary.skill(withID: checkpoint.skillID)
            ?? Skill(id: checkpoint.skillID, name: "Skill", summary: "", defaultAnchors: checkpoint.workingAnchors)
        self.checkpointAnchors = checkpoint.workingAnchors
        self.cloudKit = cloudKit
        self.log = log
        self.assessment = CheckpointAssessment(
            challengeID: challengeID,
            checkpointID: checkpoint.id,
            participantID: participant.id,
            skillID: checkpoint.skillID
        )
    }

    var anchors: [String] { checkpointAnchors }

    var orderedEvidence: [Evidence] { assessment.orderedEvidence }

    var finalRatingLevel: Int? { assessment.finalRatingLevel }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let all = try await cloudKit.fetchAll(CheckpointAssessment.self)
            if let existing = all.first(where: {
                $0.matches(checkpointID: assessment.checkpointID, participantID: assessment.participantID)
            }) {
                assessment = existing
                log.info("Loaded assessment \(existing.id)", category: .authoring)
            }
        } catch let error as AppError {
            handle(error)
        } catch {
            handle(.unknown(message: error.localizedDescription))
        }
    }

    func addPhotoNote(imageData: Data, caption: String) async {
        let evidence = Evidence(kind: .photoNote, caption: caption, imageData: imageData)
        await add(evidence)
    }

    func addHandwriting(drawingData: Data, annotatedPhoto: Data?, caption: String) async {
        let kind: EvidenceKind = annotatedPhoto == nil ? .handwritingBlank : .handwritingAnnotation
        let evidence = Evidence(kind: kind, caption: caption, imageData: annotatedPhoto, drawingData: drawingData)
        await add(evidence)
    }

    func addStudentUpload(imageData: Data, caption: String) async {
        let evidence = Evidence(kind: .studentUpload, caption: caption, imageData: imageData)
        await add(evidence)
    }

    func removeEvidence(id: UUID) async {
        assessment.removeEvidence(id: id)
        await autosave()
    }

    func setFinalRating(level: Int) async {
        guard anchors.indices.contains(level) else {
            handle(.validation(message: "Choose a rating from the rubric."))
            return
        }
        assessment.setRating(level: level)
        await autosave()
    }

    private func add(_ evidence: Evidence) async {
        assessment.add(evidence)
        await autosave()
    }

    private func autosave() async {
        isSaving = true
        defer { isSaving = false }
        do {
            try await cloudKit.save(assessment)
            log.debug("Autosaved assessment \(assessment.id)", category: .authoring)
        } catch let error as AppError {
            handle(error)
        } catch {
            handle(.unknown(message: error.localizedDescription))
        }
    }

    private func handle(_ error: AppError) {
        log.error(error, category: .authoring)
        currentError = error
    }
}
