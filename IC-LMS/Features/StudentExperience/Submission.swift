import CloudKit
import Foundation

struct Submission: Identifiable, Equatable, Codable, Sendable {
    var id: UUID
    var challengeID: UUID
    var assignmentID: UUID
    var studentName: String
    var note: String
    var imageData: Data?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        challengeID: UUID,
        assignmentID: UUID,
        studentName: String,
        note: String = "",
        imageData: Data? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.challengeID = challengeID
        self.assignmentID = assignmentID
        self.studentName = studentName
        self.note = note
        self.imageData = imageData
        self.createdAt = createdAt
    }
}

extension Submission: CloudKitRecordConvertible {
    static let recordType = "Submission"

    private enum Field {
        static let challengeID = "challengeID"
        static let assignmentID = "assignmentID"
        static let studentName = "studentName"
        static let note = "note"
        static let image = "imageData"
        static let createdAt = "createdAt"
    }

    var recordID: CKRecord.ID {
        CKRecord.ID(recordName: id.uuidString, zoneID: Submission.zoneID)
    }

    init(record: CKRecord) throws {
        guard
            let id = UUID(uuidString: record.recordID.recordName),
            let challengeIDString = record[Field.challengeID] as? String,
            let challengeID = UUID(uuidString: challengeIDString),
            let assignmentIDString = record[Field.assignmentID] as? String,
            let assignmentID = UUID(uuidString: assignmentIDString),
            let studentName = record[Field.studentName] as? String
        else {
            throw AppError.recordDecodingFailed(type: Submission.recordType)
        }
        self.init(
            id: id,
            challengeID: challengeID,
            assignmentID: assignmentID,
            studentName: studentName,
            note: record[Field.note] as? String ?? "",
            imageData: record[Field.image] as? Data,
            createdAt: record[Field.createdAt] as? Date ?? Date()
        )
    }

    func toRecord() -> CKRecord {
        let record = CKRecord(recordType: Submission.recordType, recordID: recordID)
        record[Field.challengeID] = challengeID.uuidString as CKRecordValue
        record[Field.assignmentID] = assignmentID.uuidString as CKRecordValue
        record[Field.studentName] = studentName as CKRecordValue
        record[Field.note] = note as CKRecordValue
        record[Field.createdAt] = createdAt as CKRecordValue
        if let imageData {
            record[Field.image] = imageData as CKRecordValue
        }
        return record
    }
}
