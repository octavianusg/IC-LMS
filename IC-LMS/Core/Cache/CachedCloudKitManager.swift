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
        await cacheUpsert(model)
        do {
            try await live.save(model)
        } catch let error as AppError where error.isOfflineLike {
            log.info("Saved \(T.recordType) to cache while offline", category: .cloudKit)
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
        await cacheDelete(model)
        do {
            try await live.delete(model)
        } catch let error as AppError where error.isOfflineLike {
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
        do {
            let remote = try await live.fetchAll(R.self)
            await cache.replaceAll(remote.map { ($0.cacheKey, $0) }, entity: R.cacheEntityName)
            return remote
        } catch let error as AppError where error.isOfflineLike {
            log.info("Offline; serving cached \(R.cacheEntityName)", category: .cloudKit)
            return await cache.load(R.self, entity: R.cacheEntityName)
        }
    }

    private func cacheUpsert<T: CloudKitRecordConvertible>(_ model: T) async {
        if let challenge = model as? Challenge {
            await cache.upsert(challenge, key: challenge.cacheKey, entity: Challenge.cacheEntityName)
        } else if let assessment = model as? CheckpointAssessment {
            await cache.upsert(assessment, key: assessment.cacheKey, entity: CheckpointAssessment.cacheEntityName)
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
