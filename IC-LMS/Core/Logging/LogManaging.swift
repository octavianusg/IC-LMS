import Foundation

enum LogCategory: String, Sendable {
    case app
    case authoring
    case cloudKit
}

protocol LogManaging: Sendable {
    func debug(_ message: String, category: LogCategory)
    func info(_ message: String, category: LogCategory)
    func error(_ message: String, category: LogCategory)
    func error(_ error: AppError, category: LogCategory)
}

extension LogManaging {
    func error(_ error: AppError, category: LogCategory) {
        self.error(error.diagnosticDescription, category: category)
    }
}
