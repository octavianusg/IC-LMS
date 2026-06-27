import Foundation
import Observation

@MainActor
@Observable
final class AppEnvironment {
    enum DataMode: String, CaseIterable {
        case live
        case mock
    }

    var dataMode: DataMode {
        didSet {
            guard oldValue != dataMode else { return }
            Task { await refreshAccountStatus() }
        }
    }

    private(set) var accountStatus: AccountStatus = .unknown

    let log: LogManaging
    private let liveSource: CloudKitManaging
    private let mockSource: CloudKitManaging
    private let accountProvider: AccountStatusProviding

    init(
        dataMode: DataMode,
        log: LogManaging,
        liveSource: CloudKitManaging,
        mockSource: CloudKitManaging,
        accountProvider: AccountStatusProviding
    ) {
        self.dataMode = dataMode
        self.log = log
        self.liveSource = liveSource
        self.mockSource = mockSource
        self.accountProvider = accountProvider
    }

    var isMock: Bool { dataMode == .mock }

    var activeSource: CloudKitManaging {
        dataMode == .mock ? mockSource : liveSource
    }

    func refreshAccountStatus() async {
        accountStatus = isMock ? .available : await accountProvider.currentStatus()
    }

    func makeChallengeListViewModel() -> ChallengeListViewModel {
        ChallengeListViewModel(cloudKit: activeSource, log: log)
    }

    func makeChallengeEditorViewModel(for challenge: Challenge) -> ChallengeEditorViewModel {
        ChallengeEditorViewModel(challenge: challenge, cloudKit: activeSource, log: log)
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
            cloudKit: activeSource,
            log: log
        )
    }

    func makeRunViewModel(for challenge: Challenge) -> ChallengeRunViewModel {
        ChallengeRunViewModel(challenge: challenge, log: log)
    }

    func makeStudentViewModel(for challenge: Challenge) -> StudentChallengeViewModel {
        StudentChallengeViewModel(challenge: challenge, cloudKit: activeSource, log: log)
    }

    static func makeDefault() -> AppEnvironment {
        let log = LogManager()
        let cache = CoreDataCache(log: log)
        let liveSource = CachedCloudKitManager(live: CloudKitManager(), cache: cache, log: log)
        #if DEBUG
        let mode: DataMode = .mock
        #else
        let mode: DataMode = .live
        #endif
        return AppEnvironment(
            dataMode: mode,
            log: log,
            liveSource: liveSource,
            mockSource: MockDataSource(),
            accountProvider: CloudKitAccountProvider()
        )
    }
}
