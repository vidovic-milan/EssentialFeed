import UIKit

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    private let feedPresenter: FeedPresenter

    private(set) lazy var refreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()

    init(feedPresenter: FeedPresenter) {
        self.feedPresenter = feedPresenter
    }

    @objc func refresh() {
        feedPresenter.loadFeed()
    }

    func display(isLoading: Bool) {
        if isLoading {
            refreshControl.beginRefreshing()
        } else {
            refreshControl.endRefreshing()
        }
    }
}
