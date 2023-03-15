import CoreData

public class ManagedFeedStore: FeedStore {
    private static let modelName: String = "FeedStore"
    private static let model = NSManagedObjectModel(name: modelName, bundle: Bundle(for: ManagedFeedStore.self))

    public enum ManagedFeedStoreError: Error {
        case invalidModelName
    }

    private let storeURL: URL
    private let context: NSManagedObjectContext
    private let container: NSPersistentContainer

    public init(storeURL: URL) throws {
        guard let model = ManagedFeedStore.model else {
            throw ManagedFeedStoreError.invalidModelName
        }

        self.container = try NSPersistentContainer.load(name: ManagedFeedStore.modelName, model: model, url: storeURL)

        self.storeURL = storeURL
        self.context = container.newBackgroundContext()
    }

    deinit {
        cleanUpReferencesToPersistentStores()
    }

    private func cleanUpReferencesToPersistentStores() {
        context.performAndWait {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }

    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            do {
                if let cache = try ManagedCache.find(in: context) {
                    completion(.success(.some((feed: cache.localFeed, timestamp: cache.timestamp))))
                } else {
                    completion(.success(.none))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }


    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            do {
                let cache = try ManagedCache.uniqueInstance(in: context)
                cache.feed = NSOrderedSet(array: feed.map { ManagedFeedImage.image(from: $0, in: context) })
                cache.timestamp = timestamp

                try context.save()
                completion(.success(()))
            } catch {
                context.rollback()
                completion(.failure(error))
            }
        }
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            do {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
                completion(.success(()))
            } catch {
                context.rollback()
                completion(.failure(error))
            }
        }
    }

    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        context.perform { [context] in action(context) }
    }
}
