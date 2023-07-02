import Foundation

extension ManagedFeedStore: FeedStore {

    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            completion(
               Result {
                   try ManagedCache.find(in: context).map { (feed: $0.localFeed, timestamp: $0.timestamp) }
               }
           )
        }
    }


    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            completion(
               Result {
                   let cache = try ManagedCache.uniqueInstance(in: context)
                   cache.feed = NSOrderedSet(array: feed.map { ManagedFeedImage.image(from: $0, in: context) })
                   cache.timestamp = timestamp

                   try context.save()
               }.mapError {
                   context.rollback()
                   return $0
               }
           )
        }
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            completion(
               Result {
                   try ManagedCache.find(in: context).map(context.delete).map(context.save)
               }.mapError {
                   context.rollback()
                   return $0
               }
           )
        }
    }
}
