import EssentialFeed
import UIKit

final class FeedRefreshViewController: NSObject {
    private let feedLoader: FeedLoader

    private(set) lazy var refreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()

    var onRefresh: (([FeedImage]) -> Void)?

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    @objc func refresh() {
        refreshControl.beginRefreshing()
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onRefresh?(feed)
            }
            self?.refreshControl.endRefreshing()
        }
    }
}
