import SwiftUI

@main
struct IC_LMSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var environment = AppEnvironment.makeDefault()

    var body: some Scene {
        WindowGroup {
            RootView(environment: environment)
                .onAppear { appDelegate.environment = environment }
        }
    }
}
