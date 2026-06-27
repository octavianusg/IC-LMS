import Testing
@testable import IC_LMS

@Suite("MockDataSource")
struct MockDataSourceTests {

    @Test func seedsSampleChallenges() async throws {
        let source = MockDataSource()
        let challenges = try await source.fetchAll(Challenge.self)
        #expect(!challenges.isEmpty)
    }

    @Test func seedsSampleAssessment() async throws {
        let source = MockDataSource()
        let assessments = try await source.fetchAll(CheckpointAssessment.self)
        #expect(!assessments.isEmpty)
    }

    @Test func savePersistsNewChallenge() async throws {
        let source = MockDataSource()
        let before = try await source.fetchAll(Challenge.self).count

        try await source.save(Challenge(title: "Brand New"))

        let after = try await source.fetchAll(Challenge.self)
        #expect(after.count == before + 1)
        #expect(after.contains { $0.title == "Brand New" })
    }

    @Test func deleteRemovesChallenge() async throws {
        let source = MockDataSource()
        let challenge = try await source.fetchAll(Challenge.self)[0]

        try await source.delete(challenge)

        let remaining = try await source.fetchAll(Challenge.self)
        #expect(!remaining.contains { $0.id == challenge.id })
    }
}
