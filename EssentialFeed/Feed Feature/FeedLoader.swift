public enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

public protocol FeedLoader {
    func loadFeed(completion: @escaping (LoadFeedResult) -> Void)
}
