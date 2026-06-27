import CloudKit
@testable import IC_LMS

final class MockCloudKitManager: CloudKitManaging, @unchecked Sendable {
    var storedChallenges: [Challenge] = []
    var storedAssessments: [CheckpointAssessment] = []
    var errorToThrow: AppError?

    private(set) var saveCount = 0
    private(set) var fetchCount = 0
    private(set) var deleteCount = 0

    init(
        storedChallenges: [Challenge] = [],
        storedAssessments: [CheckpointAssessment] = []
    ) {
        self.storedChallenges = storedChallenges
        self.storedAssessments = storedAssessments
    }

    func save<T: CloudKitRecordConvertible>(_ model: T) async throws {
        saveCount += 1
        if let error = errorToThrow { throw error }
        if let challenge = model as? Challenge {
            upsert(challenge, into: &storedChallenges)
        } else if let assessment = model as? CheckpointAssessment {
            upsert(assessment, into: &storedAssessments)
        }
    }

    func fetchAll<T: CloudKitRecordConvertible>(_ type: T.Type) async throws -> [T] {
        fetchCount += 1
        if let error = errorToThrow { throw error }
        if type == Challenge.self { return storedChallenges as? [T] ?? [] }
        if type == CheckpointAssessment.self { return storedAssessments as? [T] ?? [] }
        return []
    }

    func delete<T: CloudKitRecordConvertible>(_ model: T) async throws {
        deleteCount += 1
        if let error = errorToThrow { throw error }
        if let challenge = model as? Challenge {
            storedChallenges.removeAll { $0.id == challenge.id }
        } else if let assessment = model as? CheckpointAssessment {
            storedAssessments.removeAll { $0.id == assessment.id }
        }
    }

    private func upsert<Element: Identifiable>(_ element: Element, into store: inout [Element]) where Element.ID: Equatable {
        if let index = store.firstIndex(where: { $0.id == element.id }) {
            store[index] = element
        } else {
            store.append(element)
        }
    }

    func makeShare<T: CloudKitRecordConvertible>(for model: T) async throws -> CKShare {
        if let error = errorToThrow { throw error }
        return CKShare(rootRecord: model.toRecord())
    }
}
