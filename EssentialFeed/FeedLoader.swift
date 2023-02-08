enum FeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func loadFeed(completion: @escaping () -> Void)
}
