import CloudKit
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
    var pendingJoinedChallenge: Challenge?

    let log: LogManaging
    private let mockSource: CloudKitManaging
    private let accountProvider: AccountStatusProviding

    @ObservationIgnored private let liveSourceFactory: () -> CloudKitManaging
    @ObservationIgnored private lazy var liveSource: CloudKitManaging = liveSourceFactory()
    @ObservationIgnored private let sharingFactory: () -> SharingManaging
    @ObservationIgnored private lazy var sharingManager: SharingManaging = sharingFactory()

    init(
        dataMode: DataMode,
        log: LogManaging,
        mockSource: CloudKitManaging,
        accountProvider: AccountStatusProviding,
        liveSourceFactory: @escaping () -> CloudKitManaging,
        sharingFactory: @escaping () -> SharingManaging
    ) {
        self.dataMode = dataMode
        self.log = log
        self.mockSource = mockSource
        self.accountProvider = accountProvider
        self.liveSourceFactory = liveSourceFactory
        self.sharingFactory = sharingFactory
    }

    var isMock: Bool { dataMode == .mock }

    var activeSource: CloudKitManaging {
        dataMode == .mock ? mockSource : liveSource
    }

    var sharing: SharingManaging? {
        isMock ? nil : sharingManager
    }

    func refreshAccountStatus() async {
        accountStatus = isMock ? .available : await accountProvider.currentStatus()
    }

    func importSharedChallenge(from metadata: CKShare.Metadata) async {
        guard !isMock else { return }
        do {
            if let challenge = try await sharingManager.acceptShare(metadata: metadata) {
                presentJoinedChallenge(challenge)
            }
        } catch let error as AppError {
            log.error(error, category: .cloudKit)
        } catch {
            log.error(error.localizedDescription, category: .cloudKit)
        }
    }

    func presentJoinedChallenge(_ challenge: Challenge) {
        pendingJoinedChallenge = challenge
        log.info("Joined shared challenge \(challenge.id)", category: .cloudKit)
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
            },
            sharingFactory: {
                CloudKitSharingManager(log: log)
            }
        )
    }
}
