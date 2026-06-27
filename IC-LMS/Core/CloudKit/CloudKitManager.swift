import CloudKit

struct CloudKitManager: CloudKitManaging {
    private let database: CKDatabase

    init(database: CKDatabase = CKContainer.default().privateCloudDatabase) {
        self.database = database
    }

    func save<T: CloudKitRecordConvertible>(_ model: T) async throws {
        do {
            try await ensureZone(for: T.self)
            _ = try await database.save(model.toRecord())
        } catch {
            throw CloudKitErrorMapper.appError(from: error, context: "save \(T.recordType)")
        }
    }

    func fetchAll<T: CloudKitRecordConvertible>(_ type: T.Type) async throws -> [T] {
        let query = CKQuery(recordType: T.recordType, predicate: NSPredicate(value: true))
        do {
            let (results, _) = try await database.records(matching: query, inZoneWith: queryZone(for: T.self))
            return results.compactMap { _, result in
                guard let record = try? result.get() else { return nil }
                return try? T(record: record)
            }
        } catch let ckError as CKError where ckError.code == .zoneNotFound {
            return []
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
        do {
            try await ensureZone(for: T.self)
            let record = model.toRecord()
            let share = CKShare(rootRecord: record)
            share[CKShare.SystemFieldKey.title] = T.recordType as CKRecordValue
            _ = try await database.modifyRecords(saving: [record, share], deleting: [])
            return share
        } catch {
            throw CloudKitErrorMapper.appError(from: error, context: "share \(T.recordType)")
        }
    }

    private func ensureZone<T: CloudKitRecordConvertible>(for type: T.Type) async throws {
        guard T.zoneID != CloudKitZone.defaultID else { return }
        _ = try await database.modifyRecordZones(saving: [CKRecordZone(zoneID: T.zoneID)], deleting: [])
    }

    private func queryZone<T: CloudKitRecordConvertible>(for type: T.Type) -> CKRecordZone.ID? {
        T.zoneID == CloudKitZone.defaultID ? nil : T.zoneID
    }
}
