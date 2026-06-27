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
}
