import Foundation
import Observation

@MainActor
@Observable
final class StudentChallengeViewModel {
    let challenge: Challenge
    var studentName: String = ""
    private(set) var submissions: [Submission] = []
    private(set) var isLoading = false
    private(set) var isSubmitting = false
    var currentError: AppError?

    private let cloudKit: CloudKitManaging
    private let log: LogManaging

    init(challenge: Challenge, cloudKit: CloudKitManaging, log: LogManaging) {
        self.challenge = challenge
        self.cloudKit = cloudKit
        self.log = log
    }

    var visiblePhases: [ChallengePhase] {
        challenge.phases.map { phase in
            ChallengePhase(kind: phase.kind, items: phase.items.filter { $0.checkpoint == nil })
        }
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let all = try await cloudKit.fetchAll(Submission.self)
            submissions = all
                .filter { $0.challengeID == challenge.id }
                .sorted { $0.createdAt < $1.createdAt }
        } catch let error as AppError {
            handle(error)
        } catch {
            handle(.unknown(message: error.localizedDescription))
        }
    }

    func submissions(for assignmentID: UUID) -> [Submission] {
        submissions.filter { $0.assignmentID == assignmentID }
    }

    func hasSubmitted(assignmentID: UUID) -> Bool {
        let name = trimmedStudentName
        guard !name.isEmpty else { return false }
        return submissions.contains { $0.assignmentID == assignmentID && $0.studentName == name }
    }

    func submit(assignmentID: UUID, note: String, imageData: Data?) async {
        let name = trimmedStudentName
        guard !name.isEmpty else {
            handle(.validation(message: "Add your name before submitting."))
            return
        }
        let submission = Submission(
            challengeID: challenge.id,
            assignmentID: assignmentID,
            studentName: name,
            note: note,
            imageData: imageData
        )
        isSubmitting = true
        defer { isSubmitting = false }
        do {
            try await cloudKit.save(submission)
            submissions.append(submission)
            log.info("Student submitted work for assignment \(assignmentID)", category: .authoring)
        } catch let error as AppError {
            handle(error)
        } catch {
            handle(.unknown(message: error.localizedDescription))
        }
    }

    private var trimmedStudentName: String {
        studentName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func handle(_ error: AppError) {
        log.error(error, category: .authoring)
        currentError = error
    }
}
