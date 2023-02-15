public enum LoadFeedResult<Error: Equatable> {
    case success([FeedItem])
    case failure(Error)
}

extension LoadFeedResult: Equatable where Error: Equatable {}

public protocol FeedLoader {
    associatedtype Error: Equatable
    func loadFeed(completion: @escaping (LoadFeedResult<Error>) -> Void)
}
