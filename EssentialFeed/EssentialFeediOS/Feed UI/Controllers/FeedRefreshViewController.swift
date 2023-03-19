import UIKit

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    private let loadFeed: () -> Void

    private(set) lazy var refreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()

    init(loadFeed: @escaping () -> Void) {
        self.loadFeed = loadFeed
    }

    @objc func refresh() {
        loadFeed()
    }

    func display(model: FeedLoadingViewModel) {
        if model.isLoading {
            refreshControl.beginRefreshing()
        } else {
            refreshControl.endRefreshing()
        }
    }
}
