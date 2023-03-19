import EssentialFeed

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(model: FeedLoadingViewModel)
}

struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(model: FeedViewModel)
}

final class FeedPresenter {
    private let feedLoader: FeedLoader

    var feedLoadingView: FeedLoadingView?
    var feedView: FeedView?

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    func loadFeed() {
        feedLoadingView?.display(model: FeedLoadingViewModel(isLoading: true))
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(model: FeedViewModel(feed: feed))
            }
            self?.feedLoadingView?.display(model: FeedLoadingViewModel(isLoading: false))
        }
    }
}
