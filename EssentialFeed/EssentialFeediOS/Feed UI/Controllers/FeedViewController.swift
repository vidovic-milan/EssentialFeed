import UIKit
import EssentialFeed

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var imageLoader: FeedImageDataLoader?
    private var feedRefreshController: FeedRefreshViewController?
    private var feedImageCellControllers = [IndexPath: FeedImageCellController]()
    private var feed = [FeedImage]() {
        didSet { tableView.reloadData() }
    }

    convenience public init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        self.feedRefreshController = FeedRefreshViewController(feedLoader: feedLoader)
        self.imageLoader = imageLoader
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = feedRefreshController?.refreshControl
        tableView.prefetchDataSource = self
        feedRefreshController?.onRefresh = { [weak self] feed in
            self?.feed = feed
        }
        feedRefreshController?.refresh()
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return loadCellController(at: indexPath).view()
    }

    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        loadCellController(at: indexPath).preload()
    }

    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelLoadingCell(at: indexPath)
    }

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { loadCellController(at: $0).preload() }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { cancelLoadingCell(at: $0) }
    }

    private func cancelLoadingCell(at indexPath: IndexPath) {
        feedImageCellControllers[indexPath]?.cancel()
    }

    private func loadCellController(at indexPath: IndexPath) -> FeedImageCellController {
        let model = feed[indexPath.row]
        let cellController = FeedImageCellController(model: model, imageLoader: imageLoader!)
        feedImageCellControllers[indexPath] = cellController

        return cellController
    }
}
