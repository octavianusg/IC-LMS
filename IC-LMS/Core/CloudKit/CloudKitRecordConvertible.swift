import CloudKit

protocol CloudKitRecordConvertible: Identifiable {
    static var recordType: String { get }
    var recordID: CKRecord.ID { get }
    init(record: CKRecord) throws
    func toRecord() -> CKRecord
}
