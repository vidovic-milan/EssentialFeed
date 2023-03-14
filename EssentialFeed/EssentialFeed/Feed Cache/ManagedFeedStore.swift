import CoreData

public class ManagedFeedStore: FeedStore {

    public enum ManagedFeedStoreError: Error {
        case invalidModelName
    }

    private let storeURL: URL
    private let context: NSManagedObjectContext
    private static let modelName: String = "FeedStore"

    public init(storeURL: URL) throws {
        guard let model = NSManagedObjectModel(name: ManagedFeedStore.modelName, bundle: Bundle(for: ManagedFeedStore.self)) else {
            throw ManagedFeedStoreError.invalidModelName
        }

        let container = try NSPersistentContainer.load(name: ManagedFeedStore.modelName, model: model, url: storeURL)

        self.storeURL = storeURL
        self.context = container.newBackgroundContext()
    }

    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            do {
                if let cache = try ManagedCache.find(in: context) {
                    completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
                } else {
                    completion(.empty)
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
                completion(nil)
            } catch {
                context.rollback()
                completion(error)
            }
        }
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            do {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
                completion(nil)
            } catch {
                context.rollback()
                completion(error)
            }
        }
    }

    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        context.perform { [context] in action(context) }
    }
}
