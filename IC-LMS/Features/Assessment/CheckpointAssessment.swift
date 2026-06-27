import CloudKit
import Foundation

struct CheckpointAssessment: Identifiable, Equatable, Codable, Sendable {
    var id: UUID
    var challengeID: UUID
    var checkpointID: UUID
    var participantID: UUID
    var skillID: String
    var evidence: [Evidence]
    var finalRatingLevel: Int?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        challengeID: UUID,
        checkpointID: UUID,
        participantID: UUID,
        skillID: String,
        evidence: [Evidence] = [],
        finalRatingLevel: Int? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.challengeID = challengeID
        self.checkpointID = checkpointID
        self.participantID = participantID
        self.skillID = skillID
        self.evidence = evidence
        self.finalRatingLevel = finalRatingLevel
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var orderedEvidence: [Evidence] {
        evidence.sorted { $0.createdAt < $1.createdAt }
    }

    func matches(checkpointID: UUID, participantID: UUID) -> Bool {
        self.checkpointID == checkpointID && self.participantID == participantID
    }

    mutating func add(_ item: Evidence) {
        evidence.append(item)
        updatedAt = Date()
    }

    mutating func removeEvidence(id: UUID) {
        evidence.removeAll { $0.id == id }
        updatedAt = Date()
    }

    mutating func setRating(level: Int?) {
        finalRatingLevel = level
        updatedAt = Date()
    }
}

extension CheckpointAssessment: CloudKitRecordConvertible {
    static let recordType = "CheckpointAssessment"

    private enum Field {
        static let challengeID = "challengeID"
        static let checkpointID = "checkpointID"
        static let participantID = "participantID"
        static let skillID = "skillID"
        static let evidence = "evidenceData"
        static let rating = "finalRatingLevel"
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
    }

    var recordID: CKRecord.ID {
        CKRecord.ID(recordName: id.uuidString)
    }

    init(record: CKRecord) throws {
        guard
            let id = UUID(uuidString: record.recordID.recordName),
            let challengeIDString = record[Field.challengeID] as? String,
            let challengeID = UUID(uuidString: challengeIDString),
            let checkpointIDString = record[Field.checkpointID] as? String,
            let checkpointID = UUID(uuidString: checkpointIDString),
            let participantIDString = record[Field.participantID] as? String,
            let participantID = UUID(uuidString: participantIDString),
            let skillID = record[Field.skillID] as? String
        else {
            throw AppError.recordDecodingFailed(type: CheckpointAssessment.recordType)
        }

        let decodedEvidence: [Evidence]
        if let data = record[Field.evidence] as? Data,
           let evidence = try? JSONDecoder().decode([Evidence].self, from: data) {
            decodedEvidence = evidence
        } else {
            decodedEvidence = []
        }

        self.init(
            id: id,
            challengeID: challengeID,
            checkpointID: checkpointID,
            participantID: participantID,
            skillID: skillID,
            evidence: decodedEvidence,
            finalRatingLevel: record[Field.rating] as? Int,
            createdAt: record[Field.createdAt] as? Date ?? Date(),
            updatedAt: record[Field.updatedAt] as? Date ?? Date()
        )
    }

    func toRecord() -> CKRecord {
        let record = CKRecord(recordType: CheckpointAssessment.recordType, recordID: recordID)
        record[Field.challengeID] = challengeID.uuidString as CKRecordValue
        record[Field.checkpointID] = checkpointID.uuidString as CKRecordValue
        record[Field.participantID] = participantID.uuidString as CKRecordValue
        record[Field.skillID] = skillID as CKRecordValue
        record[Field.createdAt] = createdAt as CKRecordValue
        record[Field.updatedAt] = updatedAt as CKRecordValue
        if let level = finalRatingLevel {
            record[Field.rating] = level as CKRecordValue
        }
        if let data = try? JSONEncoder().encode(evidence) {
            record[Field.evidence] = data as CKRecordValue
        }
        return record
    }
}
