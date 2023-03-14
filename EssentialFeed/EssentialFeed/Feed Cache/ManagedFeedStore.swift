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
                    let cacheFeed = cache.feed.array as! [ManagedFeedImage]
                    let localFeed = cacheFeed.map { LocalFeedImage(id: $0.id, description: $0.imageDescription, location: $0.location, url: $0.url) }
                    completion(.found(feed: localFeed, timestamp: cache.timestamp))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }


    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        if let result = try? ManagedCache.find(in: self.context), let cache = result {
            context.delete(cache)
        }

        context.perform {
            let cache = ManagedCache(context: self.context)
            cache.feed = NSOrderedSet(array: feed.map { ManagedFeedImage.image(from: $0, in: self.context) })
            cache.timestamp = timestamp

            try! self.context.save()
            completion(nil)
        }
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        fatalError("Needs to be implemented")
    }
}
