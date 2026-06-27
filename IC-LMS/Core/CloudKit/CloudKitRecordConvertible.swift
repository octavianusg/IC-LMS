import CloudKit

enum CloudKitZone {
    static let shareableID = CKRecordZone.ID(zoneName: "Challenges", ownerName: CKCurrentUserDefaultName)
    static var defaultID: CKRecordZone.ID { CKRecordZone.default().zoneID }
}

protocol CloudKitRecordConvertible: Identifiable {
    static var recordType: String { get }
    static var zoneID: CKRecordZone.ID { get }
    var recordID: CKRecord.ID { get }
    init(record: CKRecord) throws
    func toRecord() -> CKRecord
}

extension CloudKitRecordConvertible {
    static var zoneID: CKRecordZone.ID { CloudKitZone.defaultID }
}
