import CloudKit
import Foundation

struct Challenge: Identifiable, Equatable, Hashable, Codable, Sendable {
    var id: UUID
    var title: String
    var summary: String
    var phases: [ChallengePhase]
    var participants: [Participant]
    var ownerName: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        summary: String = "",
        phases: [ChallengePhase] = PhaseKind.allCases.map { ChallengePhase(kind: $0) },
        participants: [Participant] = [],
        ownerName: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.phases = phases
        self.participants = participants
        self.ownerName = ownerName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    func phase(_ kind: PhaseKind) -> ChallengePhase {
        phases.first { $0.kind == kind } ?? ChallengePhase(kind: kind)
    }

    var itemCount: Int {
        phases.reduce(0) { $0 + $1.items.count }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    mutating func add(_ item: PhaseItem, to kind: PhaseKind) {
        guard let index = phases.firstIndex(where: { $0.kind == kind }) else { return }
        phases[index].items.append(item)
        updatedAt = Date()
    }

    mutating func removeItem(id: UUID, from kind: PhaseKind) {
        guard let index = phases.firstIndex(where: { $0.kind == kind }) else { return }
        phases[index].items.removeAll { $0.id == id }
        updatedAt = Date()
    }

    func checkpoints(in kind: PhaseKind) -> [Checkpoint] {
        phase(kind).items.compactMap { item in
            if case .checkpoint(let checkpoint) = item { return checkpoint }
            return nil
        }
    }

    mutating func addParticipant(name: String) {
        participants.append(Participant(name: name))
        updatedAt = Date()
    }

    mutating func removeParticipant(id: UUID) {
        participants.removeAll { $0.id == id }
        updatedAt = Date()
    }
}

extension Challenge: CloudKitRecordConvertible {
    static let recordType = "Challenge"

    private enum Field {
        static let title = "title"
        static let summary = "summary"
        static let phases = "phasesData"
        static let participants = "participantsData"
        static let ownerName = "ownerName"
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
    }

    var recordID: CKRecord.ID {
        CKRecord.ID(recordName: id.uuidString)
    }

    init(record: CKRecord) throws {
        guard
            let title = record[Field.title] as? String,
            let recordID = UUID(uuidString: record.recordID.recordName)
        else {
            throw AppError.recordDecodingFailed(type: Challenge.recordType)
        }

        let decodedPhases: [ChallengePhase]
        if let data = record[Field.phases] as? Data,
           let phases = try? JSONDecoder().decode([ChallengePhase].self, from: data) {
            decodedPhases = phases
        } else {
            decodedPhases = PhaseKind.allCases.map { ChallengePhase(kind: $0) }
        }

        let decodedParticipants: [Participant]
        if let data = record[Field.participants] as? Data,
           let participants = try? JSONDecoder().decode([Participant].self, from: data) {
            decodedParticipants = participants
        } else {
            decodedParticipants = []
        }

        self.init(
            id: recordID,
            title: title,
            summary: record[Field.summary] as? String ?? "",
            phases: decodedPhases,
            participants: decodedParticipants,
            ownerName: record[Field.ownerName] as? String ?? "",
            createdAt: record[Field.createdAt] as? Date ?? Date(),
            updatedAt: record[Field.updatedAt] as? Date ?? Date()
        )
    }

    func toRecord() -> CKRecord {
        let record = CKRecord(recordType: Challenge.recordType, recordID: recordID)
        record[Field.title] = title as CKRecordValue
        record[Field.summary] = summary as CKRecordValue
        record[Field.ownerName] = ownerName as CKRecordValue
        record[Field.createdAt] = createdAt as CKRecordValue
        record[Field.updatedAt] = updatedAt as CKRecordValue
        if let data = try? JSONEncoder().encode(phases) {
            record[Field.phases] = data as CKRecordValue
        }
        if let data = try? JSONEncoder().encode(participants) {
            record[Field.participants] = data as CKRecordValue
        }
        return record
    }
}
