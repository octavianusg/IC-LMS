import CloudKit
@testable import IC_LMS

final class MockCloudKitManager: CloudKitManaging, @unchecked Sendable {
    var storedChallenges: [Challenge] = []
    var errorToThrow: AppError?

    private(set) var saveCount = 0
    private(set) var fetchCount = 0
    private(set) var deleteCount = 0

    init(storedChallenges: [Challenge] = []) {
        self.storedChallenges = storedChallenges
    }

    func save<T: CloudKitRecordConvertible>(_ model: T) async throws {
        saveCount += 1
        if let error = errorToThrow { throw error }
        if let challenge = model as? Challenge {
            if let index = storedChallenges.firstIndex(where: { $0.id == challenge.id }) {
                storedChallenges[index] = challenge
            } else {
                storedChallenges.append(challenge)
            }
        }
    }

    func fetchAll<T: CloudKitRecordConvertible>(_ type: T.Type) async throws -> [T] {
        fetchCount += 1
        if let error = errorToThrow { throw error }
        return storedChallenges as? [T] ?? []
    }

    func delete<T: CloudKitRecordConvertible>(_ model: T) async throws {
        deleteCount += 1
        if let error = errorToThrow { throw error }
        if let challenge = model as? Challenge {
            storedChallenges.removeAll { $0.id == challenge.id }
        }
    }

    func makeShare<T: CloudKitRecordConvertible>(for model: T) async throws -> CKShare {
        if let error = errorToThrow { throw error }
        return CKShare(rootRecord: model.toRecord())
    }
}
