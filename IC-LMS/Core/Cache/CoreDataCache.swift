import CoreData
import Foundation

@MainActor
final class CoreDataCache {
    static let entityNames = ["CachedChallenge", "CachedAssessment"]

    private let container: NSPersistentContainer
    private let log: LogManaging
    private var isReady = false

    private let keyAttribute = "cacheKey"
    private let payloadAttribute = "payload"
    private let pendingAttribute = "pendingPush"

    private var lastRefresh: [String: Date] = [:]

    init(log: LogManaging, inMemory: Bool = false) {
        self.log = log
        let model = CoreDataCache.makeModel(
            entityNames: CoreDataCache.entityNames,
            keyAttribute: keyAttribute,
            payloadAttribute: payloadAttribute,
            pendingAttribute: pendingAttribute
        )
        container = NSPersistentContainer(name: "ICLMSCache", managedObjectModel: model)
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }
        container.loadPersistentStores { [weak self] _, error in
            if let error {
                self?.log.error("Cache store load failed: \(error.localizedDescription)", category: .cloudKit)
            } else {
                self?.isReady = true
            }
        }
    }

    func shouldRefresh(entity: String, minInterval: TimeInterval) -> Bool {
        let now = Date()
        if let last = lastRefresh[entity], now.timeIntervalSince(last) < minInterval {
            return false
        }
        lastRefresh[entity] = now
        return true
    }

    func load<T: Codable>(_ type: T.Type, entity: String) -> [T] {
        guard isReady else { return [] }
        let request = NSFetchRequest<NSManagedObject>(entityName: entity)
        guard let objects = try? container.viewContext.fetch(request) else { return [] }
        return objects.compactMap { decode(T.self, from: $0) }
    }

    func pendingItems<T: Codable>(_ type: T.Type, entity: String) -> [(key: String, value: T)] {
        guard isReady else { return [] }
        let request = NSFetchRequest<NSManagedObject>(entityName: entity)
        request.predicate = NSPredicate(format: "%K == %@", pendingAttribute, NSNumber(value: true))
        guard let objects = try? container.viewContext.fetch(request) else { return [] }
        return objects.compactMap { object in
            guard let key = object.value(forKey: keyAttribute) as? String,
                  let value = decode(T.self, from: object) else { return nil }
            return (key: key, value: value)
        }
    }

    func upsert<T: Codable>(_ value: T, key: String, entity: String, pending: Bool) {
        guard isReady, let data = try? JSONEncoder().encode(value) else { return }
        let object = existingObject(key: key, entity: entity)
            ?? NSEntityDescription.insertNewObject(forEntityName: entity, into: container.viewContext)
        object.setValue(key, forKey: keyAttribute)
        object.setValue(data, forKey: payloadAttribute)
        object.setValue(pending, forKey: pendingAttribute)
        save()
    }

    func delete(key: String, entity: String) {
        guard isReady, let object = existingObject(key: key, entity: entity) else { return }
        container.viewContext.delete(object)
        save()
    }

    func merge<T: Codable>(_ remote: [(key: String, value: T)], entity: String) {
        guard isReady else { return }
        let remoteKeys = Set(remote.map(\.key))

        let request = NSFetchRequest<NSManagedObject>(entityName: entity)
        if let existing = try? container.viewContext.fetch(request) {
            for object in existing {
                let key = object.value(forKey: keyAttribute) as? String
                let pending = (object.value(forKey: pendingAttribute) as? Bool) ?? false
                if let key, !pending, !remoteKeys.contains(key) {
                    container.viewContext.delete(object)
                }
            }
        }

        for item in remote {
            guard let data = try? JSONEncoder().encode(item.value) else { continue }
            let object = existingObject(key: item.key, entity: entity)
                ?? NSEntityDescription.insertNewObject(forEntityName: entity, into: container.viewContext)
            object.setValue(item.key, forKey: keyAttribute)
            object.setValue(data, forKey: payloadAttribute)
            object.setValue(false, forKey: pendingAttribute)
        }
        save()
    }

    private func decode<T: Codable>(_ type: T.Type, from object: NSManagedObject) -> T? {
        guard let data = object.value(forKey: payloadAttribute) as? Data else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private func existingObject(key: String, entity: String) -> NSManagedObject? {
        let request = NSFetchRequest<NSManagedObject>(entityName: entity)
        request.predicate = NSPredicate(format: "%K == %@", keyAttribute, key)
        request.fetchLimit = 1
        return try? container.viewContext.fetch(request).first
    }

    private func save() {
        guard container.viewContext.hasChanges else { return }
        do {
            try container.viewContext.save()
        } catch {
            log.error("Cache save failed: \(error.localizedDescription)", category: .cloudKit)
        }
    }

    private static func makeModel(
        entityNames: [String],
        keyAttribute: String,
        payloadAttribute: String,
        pendingAttribute: String
    ) -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        model.entities = entityNames.map { name in
            let entity = NSEntityDescription()
            entity.name = name
            entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)

            let key = NSAttributeDescription()
            key.name = keyAttribute
            key.attributeType = .stringAttributeType
            key.isOptional = false

            let payload = NSAttributeDescription()
            payload.name = payloadAttribute
            payload.attributeType = .binaryDataAttributeType
            payload.isOptional = true

            let pending = NSAttributeDescription()
            pending.name = pendingAttribute
            pending.attributeType = .booleanAttributeType
            pending.isOptional = false
            pending.defaultValue = false

            entity.properties = [key, payload, pending]
            return entity
        }
        return model
    }
}
