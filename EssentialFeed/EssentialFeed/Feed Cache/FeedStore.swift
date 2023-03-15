import Foundation

public typealias CacheResult = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
	typealias DeletionCompletion = (Error?) -> Void
	typealias InsertionCompletion = (Error?) -> Void

    typealias RetrievalResult = Result<CacheResult?, Error>
	typealias RetrievalCompletion = (RetrievalResult) -> Void

    /// Completion can be invoked on any queue
    /// Clients are responsible to dispatch to appropriate thread, if needed.
	func deleteCachedFeed(completion: @escaping DeletionCompletion)

    /// Completion can be invoked on any queue
    /// Clients are responsible to dispatch to appropriate thread, if needed.
	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)

    /// Completion can be invoked on any queue
    /// Clients are responsible to dispatch to appropriate thread, if needed.
	func retrieve(completion: @escaping RetrievalCompletion)
}
