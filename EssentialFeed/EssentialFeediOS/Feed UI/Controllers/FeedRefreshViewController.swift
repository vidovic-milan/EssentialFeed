import UIKit

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    private let delegate: FeedRefreshViewControllerDelegate

    private(set) lazy var refreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()

    init(feedRefreshDelegate: FeedRefreshViewControllerDelegate) {
        self.delegate = feedRefreshDelegate
    }

    @objc func refresh() {
        delegate.didRequestFeedRefresh()
    }

    func display(model: FeedLoadingViewModel) {
        if model.isLoading {
            refreshControl.beginRefreshing()
        } else {
            refreshControl.endRefreshing()
        }
    }
}
