import CloudKit

protocol CloudKitManaging: Sendable {
    func save<T: CloudKitRecordConvertible>(_ model: T) async throws
    func fetchAll<T: CloudKitRecordConvertible>(_ type: T.Type) async throws -> [T]
    func delete<T: CloudKitRecordConvertible>(_ model: T) async throws
    func makeShare<T: CloudKitRecordConvertible>(for model: T) async throws -> CKShare
}
