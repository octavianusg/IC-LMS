import CloudKit

protocol SharingManaging: Sendable {
    var container: CKContainer { get }
    func makeShare(for challenge: Challenge) async throws -> CKShare
    func acceptShare(metadata: CKShare.Metadata) async throws -> Challenge?
}

struct CloudKitSharingManager: SharingManaging {
    var container: CKContainer { containerOverride ?? .default() }

    private let containerOverride: CKContainer?
    private let log: LogManaging

    init(container: CKContainer? = nil, log: LogManaging) {
        self.containerOverride = container
        self.log = log
    }

    func makeShare(for challenge: Challenge) async throws -> CKShare {
        let database = container.privateCloudDatabase
        let record = challenge.toRecord()
        let share = CKShare(rootRecord: record)
        share[CKShare.SystemFieldKey.title] = challenge.title as CKRecordValue
        do {
            _ = try await database.modifyRecordZones(saving: [CKRecordZone(zoneID: Challenge.zoneID)], deleting: [])
            _ = try await database.modifyRecords(saving: [record, share], deleting: [])
            log.info("Created share for challenge \(challenge.id)", category: .cloudKit)
            return share
        } catch {
            throw CloudKitErrorMapper.appError(from: error, context: "share Challenge")
        }
    }

    func acceptShare(metadata: CKShare.Metadata) async throws -> Challenge? {
        let rootID = metadata.hierarchicalRootRecordID ?? metadata.rootRecordID
        do {
            _ = try await container.accept(metadata)
            let record = try await container.sharedCloudDatabase.record(for: rootID)
            let challenge = try Challenge(record: record)
            log.info("Accepted shared challenge \(challenge.id)", category: .cloudKit)
            return challenge
        } catch let error as AppError {
            throw error
        } catch {
            throw CloudKitErrorMapper.appError(from: error, context: "accept share")
        }
    }
}
