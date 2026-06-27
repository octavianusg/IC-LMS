import Foundation
import Observation

@MainActor
@Observable
final class ChallengeEditorViewModel {
    private(set) var challenge: Challenge
    private(set) var isSaving = false
    var currentError: AppError?

    let availableSkills: [Skill] = PredefinedSkillLibrary.all

    private let cloudKit: CloudKitManaging
    private let log: LogManaging

    init(challenge: Challenge, cloudKit: CloudKitManaging, log: LogManaging) {
        self.challenge = challenge
        self.cloudKit = cloudKit
        self.log = log
    }

    func addContent(_ kind: ContentKind, title: String, to phase: PhaseKind) async {
        guard let validTitle = validatedTitle(title) else { return }
        let item = ContentItem(kind: kind, title: validTitle)
        await addItem(.content(item), to: phase)
    }

    func addAssignment(title: String, to phase: PhaseKind) async {
        guard let validTitle = validatedTitle(title) else { return }
        let item = Assignment(title: validTitle)
        await addItem(.assignment(item), to: phase)
    }

    func addCheckpoint(title: String, skill: Skill, to phase: PhaseKind) async {
        guard let checkpoint = Checkpoint(title: title.trimmingCharacters(in: .whitespacesAndNewlines), skill: skill) else {
            handle(.validation(message: "Give the checkpoint a title before adding it."))
            return
        }
        await addItem(.checkpoint(checkpoint), to: phase)
    }

    func removeItem(id: UUID, from phase: PhaseKind) async {
        challenge.removeItem(id: id, from: phase)
        await autosave()
    }

    func updateDetails(title: String, summary: String) async {
        guard let validTitle = validatedTitle(title) else { return }
        challenge.title = validTitle
        challenge.summary = summary
        challenge.updatedAt = Date()
        await autosave()
    }

    private func addItem(_ item: PhaseItem, to phase: PhaseKind) async {
        challenge.add(item, to: phase)
        await autosave()
    }

    private func autosave() async {
        isSaving = true
        defer { isSaving = false }
        do {
            try await cloudKit.save(challenge)
            log.debug("Autosaved challenge \(challenge.id)", category: .authoring)
        } catch let error as AppError {
            handle(error)
        } catch {
            handle(.unknown(message: error.localizedDescription))
        }
    }

    private func validatedTitle(_ title: String) -> String? {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            handle(.validation(message: "Add a title before saving this item."))
            return nil
        }
        return trimmed
    }

    private func handle(_ error: AppError) {
        log.error(error, category: .authoring)
        currentError = error
    }
}
