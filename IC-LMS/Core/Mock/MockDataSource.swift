import CloudKit

final class MockDataSource: CloudKitManaging, @unchecked Sendable {
    private let lock = NSLock()
    private var challenges: [Challenge]
    private var assessments: [CheckpointAssessment]

    init() {
        let seeded = SampleData.challenges()
        self.challenges = seeded
        self.assessments = SampleData.assessments(for: seeded)
    }

    func save<T: CloudKitRecordConvertible>(_ model: T) async throws {
        lock.lock(); defer { lock.unlock() }
        if let challenge = model as? Challenge {
            upsert(challenge, into: &challenges)
        } else if let assessment = model as? CheckpointAssessment {
            upsert(assessment, into: &assessments)
        }
    }

    func fetchAll<T: CloudKitRecordConvertible>(_ type: T.Type) async throws -> [T] {
        lock.lock(); defer { lock.unlock() }
        if type == Challenge.self { return challenges as? [T] ?? [] }
        if type == CheckpointAssessment.self { return assessments as? [T] ?? [] }
        return []
    }

    func delete<T: CloudKitRecordConvertible>(_ model: T) async throws {
        lock.lock(); defer { lock.unlock() }
        if let challenge = model as? Challenge {
            challenges.removeAll { $0.id == challenge.id }
        } else if let assessment = model as? CheckpointAssessment {
            assessments.removeAll { $0.id == assessment.id }
        }
    }

    func makeShare<T: CloudKitRecordConvertible>(for model: T) async throws -> CKShare {
        CKShare(rootRecord: model.toRecord())
    }

    private func upsert<Element: Identifiable>(_ element: Element, into store: inout [Element]) where Element.ID: Equatable {
        if let index = store.firstIndex(where: { $0.id == element.id }) {
            store[index] = element
        } else {
            store.append(element)
        }
    }
}
