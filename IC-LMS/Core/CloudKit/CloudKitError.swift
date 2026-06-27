import CloudKit

enum CloudKitErrorMapper {
    static func appError(from error: Error, context: String) -> AppError {
        guard let ckError = error as? CKError else {
            return .unknown(message: "\(context): \(error.localizedDescription)")
        }

        switch ckError.code {
        case .notAuthenticated:
            return .notSignedIntoiCloud
        case .networkUnavailable, .networkFailure, .serviceUnavailable, .requestRateLimited:
            return .networkUnavailable
        default:
            return .unknown(message: "\(context): \(ckError.code) \(ckError.localizedDescription)")
        }
    }
}
