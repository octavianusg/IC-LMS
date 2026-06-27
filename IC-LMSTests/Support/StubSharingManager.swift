import CloudKit
@testable import IC_LMS

final class StubSharingManager: SharingManaging, @unchecked Sendable {
    var container: CKContainer { .default() }
    var challengeToReturn: Challenge?
    private(set) var madeShareCount = 0

    func makeShare(for challenge: Challenge) async throws -> CKShare {
        madeShareCount += 1
        return CKShare(rootRecord: challenge.toRecord())
    }

    func acceptShare(metadata: CKShare.Metadata) async throws -> Challenge? {
        challengeToReturn
    }
}
