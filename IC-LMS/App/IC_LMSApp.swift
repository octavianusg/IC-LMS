import SwiftUI

@main
struct IC_LMSApp: App {
    @State private var environment = AppEnvironment.makeDefault()

    var body: some Scene {
        WindowGroup {
            RootView(environment: environment)
        }
    }
}
