import Foundation
import Observation

@MainActor
@Observable
final class AppEnvironment {
    enum DataMode: String, CaseIterable {
        case live
        case mock
    }

    var dataMode: DataMode

    let log: LogManaging
    private let liveSource: CloudKitManaging
    private let mockSource: CloudKitManaging

    init(dataMode: DataMode, log: LogManaging, liveSource: CloudKitManaging, mockSource: CloudKitManaging) {
        self.dataMode = dataMode
        self.log = log
        self.liveSource = liveSource
        self.mockSource = mockSource
    }

    var isMock: Bool { dataMode == .mock }

    var activeSource: CloudKitManaging {
        dataMode == .mock ? mockSource : liveSource
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
            liveSource: CloudKitManager(),
            mockSource: MockDataSource()
        )
    }
}
