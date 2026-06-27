import Foundation

struct AppDependencies {
    let cloudKit: CloudKitManaging
    let log: LogManaging

    static let live: AppDependencies = {
        let log = LogManager()
        return AppDependencies(cloudKit: CloudKitManager(), log: log)
    }()

    func makeChallengeListViewModel() -> ChallengeListViewModel {
        ChallengeListViewModel(cloudKit: cloudKit, log: log)
    }

    func makeChallengeEditorViewModel(for challenge: Challenge) -> ChallengeEditorViewModel {
        ChallengeEditorViewModel(challenge: challenge, cloudKit: cloudKit, log: log)
    }

    func makeAssessmentViewModel(
        challengeID: UUID,
        checkpoint: Checkpoint,
        participant: Participant
    ) -> AssessmentViewModel {
        AssessmentViewModel(
            challengeID: challengeID,
            checkpoint: checkpoint,
            participant: participant,
            cloudKit: cloudKit,
            log: log
        )
    }

    func makeRunViewModel(for challenge: Challenge) -> ChallengeRunViewModel {
        ChallengeRunViewModel(challenge: challenge, log: log)
    }
}
