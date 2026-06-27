import SwiftUI

struct RootView: View {
    @State private var environment: AppEnvironment

    init(environment: AppEnvironment) {
        _environment = State(initialValue: environment)
    }

    var body: some View {
        ChallengeListView(
            viewModel: environment.makeChallengeListViewModel(),
            environment: environment
        )
        .id(environment.dataMode)
        .overlay(alignment: .bottomTrailing) {
            #if DEBUG
            DebugDataModeSwitch(environment: environment)
            #endif
        }
    }
}
