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

    init(log: LogManaging, inMemory: Bool = false) {
        self.log = log
        let model = CoreDataCache.makeModel(
            entityNames: CoreDataCache.entityNames,
            keyAttribute: keyAttribute,
            payloadAttribute: payloadAttribute
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

    func load<T: Codable>(_ type: T.Type, entity: String) -> [T] {
        guard isReady else { return [] }
        let request = NSFetchRequest<NSManagedObject>(entityName: entity)
        guard let objects = try? container.viewContext.fetch(request) else { return [] }
        return objects.compactMap { object in
            guard let data = object.value(forKey: payloadAttribute) as? Data else { return nil }
            return try? JSONDecoder().decode(T.self, from: data)
        }
    }

    func upsert<T: Codable>(_ value: T, key: String, entity: String) {
        guard isReady, let data = try? JSONEncoder().encode(value) else { return }
        let object = existingObject(key: key, entity: entity)
            ?? NSEntityDescription.insertNewObject(forEntityName: entity, into: container.viewContext)
        object.setValue(key, forKey: keyAttribute)
        object.setValue(data, forKey: payloadAttribute)
        save()
    }

    func delete(key: String, entity: String) {
        guard isReady, let object = existingObject(key: key, entity: entity) else { return }
        container.viewContext.delete(object)
        save()
    }

    func replaceAll<T: Codable>(_ values: [(key: String, value: T)], entity: String) {
        guard isReady else { return }
        let request = NSFetchRequest<NSManagedObject>(entityName: entity)
        if let existing = try? container.viewContext.fetch(request) {
            existing.forEach(container.viewContext.delete)
        }
        for item in values {
            guard let data = try? JSONEncoder().encode(item.value) else { continue }
            let object = NSEntityDescription.insertNewObject(forEntityName: entity, into: container.viewContext)
            object.setValue(item.key, forKey: keyAttribute)
            object.setValue(data, forKey: payloadAttribute)
        }
        save()
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
        payloadAttribute: String
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

            entity.properties = [key, payload]
            return entity
        }
        return model
    }
}
