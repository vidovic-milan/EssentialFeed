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

        self.storeURL = storeURL

        let container = NSPersistentContainer(name: ManagedFeedStore.modelName, managedObjectModel: model)
        
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeURL)]
        container.loadPersistentStores(completionHandler: { _, _ in })
        self.context = container.newBackgroundContext()
    }

    public func retrieve(completion: @escaping RetrievalCompletion) {
        context.perform {
            let fetchedCache = try? self.context.fetch(NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!))
            if let cache = fetchedCache?.first {
                let cacheFeed = cache.feed.array as! [ManagedFeedImage]
                let localFeed = cacheFeed.map { LocalFeedImage(id: $0.id, description: $0.imageDescription, location: $0.location, url: $0.url) }
                completion(.found(feed: localFeed, timestamp: cache.timestamp))
            } else {
                completion(.empty)
            }
        }
    }


    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        context.perform {
            let managedImages = feed.map { local in
                let managedImage = ManagedFeedImage(context: self.context)
                managedImage.id = local.id
                managedImage.location = local.location
                managedImage.imageDescription = local.description
                managedImage.url = local.url
                return managedImage
            }
            let cache = ManagedCache(context: self.context)
            cache.feed = NSOrderedSet(array: managedImages)
            cache.timestamp = timestamp

            try! self.context.save()
            completion(nil)
        }
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        fatalError("Needs to be implemented")
    }
}
