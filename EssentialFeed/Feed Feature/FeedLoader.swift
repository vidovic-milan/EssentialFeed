public enum LoadFeedResult<Error: Equatable> {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    associatedtype Error: Equatable
    func loadFeed(completion: @escaping (LoadFeedResult<Error>) -> Void)
}
