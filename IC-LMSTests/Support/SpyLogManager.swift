@testable import IC_LMS

final class SpyLogManager: LogManaging, @unchecked Sendable {
    struct Entry {
        let level: String
        let message: String
        let category: LogCategory
    }

    private(set) var entries: [Entry] = []

    var errorCount: Int { entries.filter { $0.level == "error" }.count }

    func debug(_ message: String, category: LogCategory) {
        entries.append(Entry(level: "debug", message: message, category: category))
    }

    func info(_ message: String, category: LogCategory) {
        entries.append(Entry(level: "info", message: message, category: category))
    }

    func error(_ message: String, category: LogCategory) {
        entries.append(Entry(level: "error", message: message, category: category))
    }
}
