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

    var feedLoadingView: FeedLoadingView?
    var feedView: FeedView?

    func didStartLoadingFeed() {
        feedLoadingView?.display(model: FeedLoadingViewModel(isLoading: true))
    }

    func didLoadFeed(with feed: [FeedImage]) {
        feedView?.display(model: FeedViewModel(feed: feed))
        feedLoadingView?.display(model: FeedLoadingViewModel(isLoading: false))
    }

    func didFailLoadingFeed(with error: Error) {
        feedLoadingView?.display(model: FeedLoadingViewModel(isLoading: false))
    }
}
