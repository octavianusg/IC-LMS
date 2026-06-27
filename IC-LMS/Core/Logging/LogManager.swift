import Foundation
import os

struct LogManager: LogManaging {
    private let subsystem: String

    init(subsystem: String = Bundle.main.bundleIdentifier ?? "IC-LMS") {
        self.subsystem = subsystem
    }

    private func logger(for category: LogCategory) -> Logger {
        Logger(subsystem: subsystem, category: category.rawValue)
    }

    func debug(_ message: String, category: LogCategory) {
        logger(for: category).debug("\(message, privacy: .public)")
    }

    func info(_ message: String, category: LogCategory) {
        logger(for: category).info("\(message, privacy: .public)")
    }

    func error(_ message: String, category: LogCategory) {
        logger(for: category).error("\(message, privacy: .public)")
    }
}
