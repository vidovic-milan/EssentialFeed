import UIKit

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    var delegate: FeedRefreshViewControllerDelegate?

    @IBOutlet private(set) public var refreshControl: UIRefreshControl!

    @IBAction func refresh() {
        delegate?.didRequestFeedRefresh()
    }

    func display(model: FeedLoadingViewModel) {
        if model.isLoading {
            refreshControl.beginRefreshing()
        } else {
            refreshControl.endRefreshing()
        }
    }
}
