import Foundation

enum AppError: LocalizedError, Equatable {
    case persistenceFailed(reason: String)
    case fetchFailed(reason: String)
    case recordDecodingFailed(type: String)
    case validation(message: String)
    case notSignedIntoiCloud
    case networkUnavailable
    case unknown(message: String)

    var errorDescription: String? {
        switch self {
        case .persistenceFailed:
            return "We couldn't save your changes. Please try again."
        case .fetchFailed:
            return "We couldn't load your challenges. Please try again."
        case .recordDecodingFailed:
            return "Some data couldn't be read and was skipped."
        case .validation(let message):
            return message
        case .notSignedIntoiCloud:
            return "Sign in to iCloud to create and sync challenges."
        case .networkUnavailable:
            return "You appear to be offline. Changes will sync when you reconnect."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }

    var diagnosticDescription: String {
        switch self {
        case .persistenceFailed(let reason):
            return "persistenceFailed: \(reason)"
        case .fetchFailed(let reason):
            return "fetchFailed: \(reason)"
        case .recordDecodingFailed(let type):
            return "recordDecodingFailed: \(type)"
        case .validation(let message):
            return "validation: \(message)"
        case .notSignedIntoiCloud:
            return "notSignedIntoiCloud"
        case .networkUnavailable:
            return "networkUnavailable"
        case .unknown(let message):
            return "unknown: \(message)"
        }
    }
}
