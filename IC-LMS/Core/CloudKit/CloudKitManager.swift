import CloudKit

struct CloudKitManager: CloudKitManaging {
    private let database: CKDatabase

    init(database: CKDatabase = CKContainer.default().privateCloudDatabase) {
        self.database = database
    }

    func save<T: CloudKitRecordConvertible>(_ model: T) async throws {
        do {
            _ = try await database.save(model.toRecord())
        } catch {
            throw CloudKitErrorMapper.appError(from: error, context: "save \(T.recordType)")
        }
    }

    func fetchAll<T: CloudKitRecordConvertible>(_ type: T.Type) async throws -> [T] {
        let query = CKQuery(recordType: T.recordType, predicate: NSPredicate(value: true))
        do {
            let (results, _) = try await database.records(matching: query)
            return results.compactMap { _, result in
                guard let record = try? result.get() else { return nil }
                return try? T(record: record)
            }
        } catch {
            throw CloudKitErrorMapper.appError(from: error, context: "fetch \(T.recordType)")
        }
    }

    func delete<T: CloudKitRecordConvertible>(_ model: T) async throws {
        do {
            _ = try await database.deleteRecord(withID: model.recordID)
        } catch {
            throw CloudKitErrorMapper.appError(from: error, context: "delete \(T.recordType)")
        }
    }

    func makeShare<T: CloudKitRecordConvertible>(for model: T) async throws -> CKShare {
        let record = model.toRecord()
        let share = CKShare(rootRecord: record)
        do {
            _ = try await database.modifyRecords(saving: [record, share], deleting: [])
            return share
        } catch {
            throw CloudKitErrorMapper.appError(from: error, context: "share \(T.recordType)")
        }
    }
}
