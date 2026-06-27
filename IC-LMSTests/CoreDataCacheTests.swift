import Testing
@testable import IC_LMS

@MainActor
@Suite("CoreDataCache merge")
struct CoreDataCacheTests {

    private let entity = Challenge.cacheEntityName

    private func makeCache() -> CoreDataCache {
        CoreDataCache(log: SpyLogManager(), inMemory: true)
    }

    @Test func mergePreservesPendingRecordsAbsentFromRemote() {
        let cache = makeCache()
        let offline = Challenge(title: "Offline")
        cache.upsert(offline, key: offline.cacheKey, entity: entity, pending: true)

        let emptyRemote: [(key: String, value: Challenge)] = []
        cache.merge(emptyRemote, entity: entity)

        #expect(cache.load(Challenge.self, entity: entity).contains { $0.id == offline.id })
    }

    @Test func mergeRemovesSyncedRecordsAbsentFromRemote() {
        let cache = makeCache()
        let synced = Challenge(title: "WasRemote")
        cache.upsert(synced, key: synced.cacheKey, entity: entity, pending: false)

        let emptyRemote: [(key: String, value: Challenge)] = []
        cache.merge(emptyRemote, entity: entity)

        #expect(cache.load(Challenge.self, entity: entity).isEmpty)
    }

    @Test func mergeClearsPendingWhenRecordAppearsRemotely() {
        let cache = makeCache()
        let item = Challenge(title: "Pushed")
        cache.upsert(item, key: item.cacheKey, entity: entity, pending: true)

        cache.merge([(key: item.cacheKey, value: item)], entity: entity)

        #expect(cache.pendingItems(Challenge.self, entity: entity).isEmpty)
        #expect(cache.load(Challenge.self, entity: entity).count == 1)
    }

    @Test func pendingItemsReturnsOnlyUnsyncedRecords() {
        let cache = makeCache()
        let offline = Challenge(title: "Offline")
        let synced = Challenge(title: "Synced")
        cache.upsert(offline, key: offline.cacheKey, entity: entity, pending: true)
        cache.upsert(synced, key: synced.cacheKey, entity: entity, pending: false)

        let pending = cache.pendingItems(Challenge.self, entity: entity)

        #expect(pending.count == 1)
        #expect(pending.first?.value.id == offline.id)
    }
}
