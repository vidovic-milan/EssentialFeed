import Foundation
import EssentialFeed

protocol FeedLoadingView {
    func display(model: FeedLoadingViewModel)
}

protocol FeedView {
    func display(model: FeedViewModel)
}

final class FeedPresenter {

    private let feedLoadingView: FeedLoadingView
    private let feedView: FeedView

    internal init(feedLoadingView: FeedLoadingView, feedView: FeedView) {
        self.feedLoadingView = feedLoadingView
        self.feedView = feedView
    }

    static var title: String {
        return NSLocalizedString(
            "FEED_VIEW_TITLE",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Title for the feed view"
        )
    }

    func didStartLoadingFeed() {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async { [weak self] in self?.didStartLoadingFeed() }
        }
        feedLoadingView.display(model: FeedLoadingViewModel(isLoading: true))
    }

    func didLoadFeed(with feed: [FeedImage]) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async { [weak self] in self?.didLoadFeed(with: feed) }
        }
        feedView.display(model: FeedViewModel(feed: feed))
        feedLoadingView.display(model: FeedLoadingViewModel(isLoading: false))
    }

    func didFailLoadingFeed(with error: Error) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async { [weak self] in self?.didFailLoadingFeed(with: error) }
        }
        feedLoadingView.display(model: FeedLoadingViewModel(isLoading: false))
    }
}
