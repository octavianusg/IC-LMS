import Foundation

protocol CacheableRecord: CloudKitRecordConvertible, Codable {
    static var cacheEntityName: String { get }
    var cacheKey: String { get }
}

extension Challenge: CacheableRecord {
    static var cacheEntityName: String { "CachedChallenge" }
    var cacheKey: String { id.uuidString }
}

extension CheckpointAssessment: CacheableRecord {
    static var cacheEntityName: String { "CachedAssessment" }
    var cacheKey: String { id.uuidString }
}
