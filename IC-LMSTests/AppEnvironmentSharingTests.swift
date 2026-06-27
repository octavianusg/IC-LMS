import Testing
@testable import IC_LMS

@MainActor
@Suite("AppEnvironment sharing")
struct AppEnvironmentSharingTests {

    private func makeEnvironment(mode: AppEnvironment.DataMode) -> AppEnvironment {
        AppEnvironment(
            dataMode: mode,
            log: SpyLogManager(),
            mockSource: MockDataSource(),
            accountProvider: StaticAccountProvider(status: .available),
            liveSourceFactory: { MockCloudKitManager() },
            sharingFactory: { StubSharingManager() }
        )
    }

    @Test func sharingIsUnavailableInMockMode() {
        let environment = makeEnvironment(mode: .mock)
        #expect(environment.sharing == nil)
    }

    @Test func sharingIsAvailableInLiveMode() {
        let environment = makeEnvironment(mode: .live)
        #expect(environment.sharing != nil)
    }

    @Test func presentingJoinedChallengeSetsPending() {
        let environment = makeEnvironment(mode: .live)
        let challenge = Challenge(title: "Shared")

        environment.presentJoinedChallenge(challenge)

        #expect(environment.pendingJoinedChallenge?.id == challenge.id)
    }

    @Test func accountAvailableInMockMode() async {
        let environment = makeEnvironment(mode: .mock)
        await environment.refreshAccountStatus()
        #expect(environment.accountStatus == .available)
    }
}
