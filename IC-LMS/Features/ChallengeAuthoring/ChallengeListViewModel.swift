import Foundation
import Observation

@MainActor
@Observable
final class ChallengeListViewModel {
    private(set) var challenges: [Challenge] = []
    private(set) var isLoading = false
    var currentError: AppError?

    private let cloudKit: CloudKitManaging
    private let log: LogManaging

    init(cloudKit: CloudKitManaging, log: LogManaging) {
        self.cloudKit = cloudKit
        self.log = log
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let fetched = try await cloudKit.fetchAll(Challenge.self)
            challenges = fetched.sorted { $0.updatedAt > $1.updatedAt }
            log.info("Loaded \(challenges.count) challenges", category: .authoring)
        } catch let error as AppError {
            handle(error)
        } catch {
            handle(.unknown(message: error.localizedDescription))
        }
    }

    @discardableResult
    func createChallenge(title: String) async -> Challenge? {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            handle(.validation(message: "Give your challenge a title to get started."))
            return nil
        }

        let challenge = Challenge(title: trimmed)
        do {
            try await cloudKit.save(challenge)
            challenges.insert(challenge, at: 0)
            log.info("Created challenge \(challenge.id)", category: .authoring)
            return challenge
        } catch let error as AppError {
            handle(error)
            return nil
        } catch {
            handle(.unknown(message: error.localizedDescription))
            return nil
        }
    }

    func delete(_ challenge: Challenge) async {
        do {
            try await cloudKit.delete(challenge)
            challenges.removeAll { $0.id == challenge.id }
            log.info("Deleted challenge \(challenge.id)", category: .authoring)
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
