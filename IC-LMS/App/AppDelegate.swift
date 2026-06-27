import CloudKit
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    weak var environment: AppEnvironment?

    func application(
        _ application: UIApplication,
        userDidAcceptCloudKitShareWith metadata: CKShare.Metadata
    ) {
        Task { @MainActor [weak self] in
            await self?.environment?.importSharedChallenge(from: metadata)
        }
    }
}
