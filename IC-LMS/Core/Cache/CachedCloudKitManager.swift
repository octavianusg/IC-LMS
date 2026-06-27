import CloudKit

struct CachedCloudKitManager: CloudKitManaging {
    private let live: CloudKitManaging
    private let cache: CoreDataCache
    private let log: LogManaging

    init(live: CloudKitManaging, cache: CoreDataCache, log: LogManaging) {
        self.live = live
        self.cache = cache
        self.log = log
    }

    func save<T: CloudKitRecordConvertible>(_ model: T) async throws {
        do {
            try await live.save(model)
            await cacheUpsert(model, pending: false)
        } catch let error as AppError where error.isOfflineLike {
            await cacheUpsert(model, pending: true)
            log.info("Saved \(T.recordType) to cache while offline (pending sync)", category: .cloudKit)
        }
    }

    func fetchAll<T: CloudKitRecordConvertible>(_ type: T.Type) async throws -> [T] {
        if type == Challenge.self {
            return try await cachedFetch(Challenge.self) as? [T] ?? []
        }
        if type == CheckpointAssessment.self {
            return try await cachedFetch(CheckpointAssessment.self) as? [T] ?? []
        }
        return try await live.fetchAll(type)
    }

    func delete<T: CloudKitRecordConvertible>(_ model: T) async throws {
        do {
            try await live.delete(model)
            await cacheDelete(model)
        } catch let error as AppError where error.isOfflineLike {
            await cacheDelete(model)
            log.info("Deleted \(T.recordType) from cache while offline", category: .cloudKit)
        }
    }

    func makeShare<T: CloudKitRecordConvertible>(for model: T) async throws -> CKShare {
        try await live.makeShare(for: model)
    }

    private func cachedFetch<R: CacheableRecord>(_ type: R.Type) async throws -> [R] {
        let cached = await cache.load(R.self, entity: R.cacheEntityName)
        if cached.isEmpty {
            return try await refresh(R.self)
        }
        Task { _ = try? await refresh(R.self) }
        return cached
    }

    private func refresh<R: CacheableRecord>(_ type: R.Type) async throws -> [R] {
        await flushPending(R.self)
        do {
            let remote = try await live.fetchAll(R.self)
            await cache.merge(remote.map { (key: $0.cacheKey, value: $0) }, entity: R.cacheEntityName)
            return await cache.load(R.self, entity: R.cacheEntityName)
        } catch let error as AppError where error.isOfflineLike {
            log.info("Offline; serving cached \(R.cacheEntityName)", category: .cloudKit)
            return await cache.load(R.self, entity: R.cacheEntityName)
        }
    }

    private func flushPending<R: CacheableRecord>(_ type: R.Type) async {
        let pending = await cache.pendingItems(R.self, entity: R.cacheEntityName)
        for item in pending {
            do {
                try await live.save(item.value)
            } catch let error as AppError where error.isOfflineLike {
                return
            } catch {
                log.error("Pending push failed for \(R.cacheEntityName): \(error.localizedDescription)", category: .cloudKit)
            }
        }
    }

    private func cacheUpsert<T: CloudKitRecordConvertible>(_ model: T, pending: Bool) async {
        if let challenge = model as? Challenge {
            await cache.upsert(challenge, key: challenge.cacheKey, entity: Challenge.cacheEntityName, pending: pending)
        } else if let assessment = model as? CheckpointAssessment {
            await cache.upsert(assessment, key: assessment.cacheKey, entity: CheckpointAssessment.cacheEntityName, pending: pending)
        }
    }

    private func cacheDelete<T: CloudKitRecordConvertible>(_ model: T) async {
        if let challenge = model as? Challenge {
            await cache.delete(key: challenge.cacheKey, entity: Challenge.cacheEntityName)
        } else if let assessment = model as? CheckpointAssessment {
            await cache.delete(key: assessment.cacheKey, entity: CheckpointAssessment.cacheEntityName)
        }
    }
}
