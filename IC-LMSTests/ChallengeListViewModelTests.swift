import Testing
import Foundation
@testable import IC_LMS

@MainActor
@Suite("ChallengeListViewModel")
struct ChallengeListViewModelTests {

    private func makeViewModel(
        cloudKit: MockCloudKitManager = MockCloudKitManager(),
        log: SpyLogManager = SpyLogManager()
    ) -> ChallengeListViewModel {
        ChallengeListViewModel(cloudKit: cloudKit, log: log)
    }

    @Test func loadPopulatesAndSortsByUpdatedAt() async {
        let older = Challenge(title: "Older", updatedAt: Date(timeIntervalSince1970: 100))
        let newer = Challenge(title: "Newer", updatedAt: Date(timeIntervalSince1970: 200))
        let cloudKit = MockCloudKitManager(storedChallenges: [older, newer])
        let viewModel = makeViewModel(cloudKit: cloudKit)

        await viewModel.load()

        #expect(viewModel.challenges.map(\.title) == ["Newer", "Older"])
        #expect(viewModel.currentError == nil)
        #expect(viewModel.isLoading == false)
    }

    @Test func loadFailureSurfacesErrorAndLogs() async {
        let cloudKit = MockCloudKitManager()
        cloudKit.errorToThrow = .networkUnavailable
        let log = SpyLogManager()
        let viewModel = makeViewModel(cloudKit: cloudKit, log: log)

        await viewModel.load()

        #expect(viewModel.currentError == .networkUnavailable)
        #expect(log.errorCount == 1)
    }

    @Test func createValidChallengePersistsAndInserts() async {
        let cloudKit = MockCloudKitManager()
        let viewModel = makeViewModel(cloudKit: cloudKit)

        let created = await viewModel.createChallenge(title: "  Water Cycle  ")

        #expect(created?.title == "Water Cycle")
        #expect(viewModel.challenges.first?.title == "Water Cycle")
        #expect(cloudKit.storedChallenges.count == 1)
        #expect(cloudKit.saveCount == 1)
    }

    @Test func createEmptyTitleValidatesAndDoesNotPersist() async {
        let cloudKit = MockCloudKitManager()
        let viewModel = makeViewModel(cloudKit: cloudKit)

        let created = await viewModel.createChallenge(title: "   ")

        #expect(created == nil)
        #expect(cloudKit.saveCount == 0)
        if case .validation = viewModel.currentError {} else {
            Issue.record("Expected validation error")
        }
    }

    @Test func deleteRemovesChallenge() async {
        let challenge = Challenge(title: "Remove Me")
        let cloudKit = MockCloudKitManager(storedChallenges: [challenge])
        let viewModel = makeViewModel(cloudKit: cloudKit)
        await viewModel.load()

        await viewModel.delete(challenge)

        #expect(viewModel.challenges.isEmpty)
        #expect(cloudKit.storedChallenges.isEmpty)
        #expect(cloudKit.deleteCount == 1)
    }
}
