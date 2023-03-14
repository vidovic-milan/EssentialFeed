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
        context.perform {
            do {
                if let cache = try ManagedCache.find(in: self.context) {
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
        context.perform {
            do {
                if let cache = try ManagedCache.find(in: self.context) {
                    self.context.delete(cache)
                }

                let cache = ManagedCache(context: self.context)
                cache.feed = NSOrderedSet(array: feed.map { ManagedFeedImage.image(from: $0, in: self.context) })
                cache.timestamp = timestamp

                try self.context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        context.perform {
            try! ManagedCache.find(in: self.context).map(self.context.delete).map(self.context.save)
            completion(nil)
        }
    }
}
