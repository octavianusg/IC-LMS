import CloudKit

enum AccountStatus: Sendable {
    case available
    case noAccount
    case restricted
    case unknown

    var isAvailable: Bool { self == .available }

    var bannerMessage: String? {
        switch self {
        case .available:
            return nil
        case .noAccount:
            return "Not signed in to iCloud. You can keep working; changes sync once you sign in."
        case .restricted:
            return "iCloud is restricted on this device. You can keep working locally."
        case .unknown:
            return "iCloud is unavailable right now. You can keep working locally."
        }
    }
}

protocol AccountStatusProviding: Sendable {
    func currentStatus() async -> AccountStatus
}

struct CloudKitAccountProvider: AccountStatusProviding {
    private let container: CKContainer

    init(container: CKContainer = .default()) {
        self.container = container
    }

    func currentStatus() async -> AccountStatus {
        do {
            switch try await container.accountStatus() {
            case .available:
                return .available
            case .noAccount:
                return .noAccount
            case .restricted:
                return .restricted
            default:
                return .unknown
            }
        } catch {
            return .unknown
        }
    }
}

struct StaticAccountProvider: AccountStatusProviding {
    let status: AccountStatus

    func currentStatus() async -> AccountStatus { status }
}
