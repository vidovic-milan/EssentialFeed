import EssentialFeed
import UIKit

final class FeedViewModel {
    private enum State {
        case pending
        case loading
        case loaded(feed: [FeedImage])
        case failed
    }

    private var state: State = .pending {
        didSet { onChange?(self) }
    }
    private let feedLoader: FeedLoader

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    var onChange: ((FeedViewModel) -> Void)?
    var isLoading: Bool {
        switch state {
        case .loading: return true
        case .loaded, .failed, .pending: return false
        }
    }
    var feed: [FeedImage]? {
        switch state {
        case .loaded(let feed): return feed
        case .loading, .failed, .pending: return nil
        }
    }

    func loadFeed() {
        state = .loading
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.state = .loaded(feed: feed)
            } else {
                self?.state = .failed
            }
        }
    }
}

final class FeedRefreshViewController: NSObject {
    private let feedViewModel: FeedViewModel

    private(set) lazy var refreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()

    var onRefresh: (([FeedImage]) -> Void)?

    init(feedLoader: FeedLoader) {
        self.feedViewModel = FeedViewModel(feedLoader: feedLoader)
    }

    @objc func refresh() {
        feedViewModel.onChange = { [weak self] viewModel in
            if viewModel.isLoading {
                self?.refreshControl.beginRefreshing()
            } else {
                self?.refreshControl.endRefreshing()
            }
            
            if let feed = viewModel.feed {
                self?.onRefresh?(feed)
            }
        }
        feedViewModel.loadFeed()
    }
}
