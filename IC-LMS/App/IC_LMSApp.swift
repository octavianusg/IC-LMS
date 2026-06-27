import SwiftUI

@main
struct IC_LMSApp: App {
    private let dependencies = AppDependencies.live

    var body: some Scene {
        WindowGroup {
            ChallengeListView(viewModel: dependencies.makeChallengeListViewModel(), dependencies: dependencies)
        }
    }
}
