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
    private let mockSource: CloudKitManaging
    private let accountProvider: AccountStatusProviding

    @ObservationIgnored private let liveSourceFactory: () -> CloudKitManaging
    @ObservationIgnored private lazy var liveSource: CloudKitManaging = liveSourceFactory()

    init(
        dataMode: DataMode,
        log: LogManaging,
        mockSource: CloudKitManaging,
        accountProvider: AccountStatusProviding,
        liveSourceFactory: @escaping () -> CloudKitManaging
    ) {
        self.dataMode = dataMode
        self.log = log
        self.mockSource = mockSource
        self.accountProvider = accountProvider
        self.liveSourceFactory = liveSourceFactory
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
        #if DEBUG
        let mode: DataMode = .mock
        #else
        let mode: DataMode = .live
        #endif
        return AppEnvironment(
            dataMode: mode,
            log: log,
            mockSource: MockDataSource(),
            accountProvider: CloudKitAccountProvider(),
            liveSourceFactory: {
                CachedCloudKitManager(live: CloudKitManager(), cache: CoreDataCache(log: log), log: log)
            }
        )
    }
}
