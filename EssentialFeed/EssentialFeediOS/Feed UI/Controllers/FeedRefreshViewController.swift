import UIKit

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
        feedViewModel.onLoadingStateChange = { [weak refreshControl] isLoading in
            if isLoading {
                refreshControl?.beginRefreshing()
            } else {
                refreshControl?.endRefreshing()
            }
        }
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }
}
