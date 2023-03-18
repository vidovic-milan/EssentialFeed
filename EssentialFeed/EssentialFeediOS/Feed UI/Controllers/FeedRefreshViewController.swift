import EssentialFeed
import UIKit

final class FeedViewModel {
    typealias Observer<T> = (T) -> Void
    private let feedLoader: FeedLoader

    var onChange: Observer<FeedViewModel>?
    var onLoad: Observer<[FeedImage]>?

    private(set) var isLoading: Bool = false {
        didSet { onChange?(self) }
    }

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    func loadFeed() {
        isLoading = true
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onLoad?(feed)
            }
            self?.isLoading = false
        }
    }
}

final class FeedRefreshViewController: NSObject {
    private let feedViewModel: FeedViewModel

    private(set) lazy var refreshControl = binded(UIRefreshControl())

    init(feedViewModel: FeedViewModel) {
        self.feedViewModel = feedViewModel
    }

    @objc func refresh() {
        feedViewModel.loadFeed()
    }

    private func binded(_ refreshControl: UIRefreshControl) -> UIRefreshControl {
        feedViewModel.onChange = { [weak refreshControl] viewModel in
            if viewModel.isLoading {
                refreshControl?.beginRefreshing()
            } else {
                refreshControl?.endRefreshing()
            }
        }
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }
}
