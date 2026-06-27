import Testing
@testable import IC_LMS

@MainActor
@Suite("CachedCloudKitManager")
struct CachedCloudKitManagerTests {

    private func makeManager(live: MockCloudKitManager) -> CachedCloudKitManager {
        let cache = CoreDataCache(log: SpyLogManager(), inMemory: true)
        return CachedCloudKitManager(live: live, cache: cache, log: SpyLogManager())
    }

    @Test func emptyCachePopulatesFromLive() async throws {
        let live = MockCloudKitManager(storedChallenges: [Challenge(title: "Seed")])
        let manager = makeManager(live: live)

        let result = try await manager.fetchAll(Challenge.self)

        #expect(result.count == 1)
        #expect(result.first?.title == "Seed")
    }

    @Test func saveWritesThroughToLiveAndIsReadable() async throws {
        let live = MockCloudKitManager()
        let manager = makeManager(live: live)

        try await manager.save(Challenge(title: "New"))

        #expect(live.storedChallenges.count == 1)
        let fetched = try await manager.fetchAll(Challenge.self)
        #expect(fetched.contains { $0.title == "New" })
    }

    @Test func offlineSaveIsCachedAndDoesNotThrow() async throws {
        let live = MockCloudKitManager()
        live.errorToThrow = .networkUnavailable
        let manager = makeManager(live: live)

        try await manager.save(Challenge(title: "Offline"))

        #expect(live.storedChallenges.isEmpty)
        let fetched = try await manager.fetchAll(Challenge.self)
        #expect(fetched.contains { $0.title == "Offline" })
    }
}
