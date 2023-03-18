import UIKit

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var feedRefreshController: FeedRefreshViewController?

    var cellControllers = [FeedImageCellController]() {
        didSet { tableView.reloadData() }
    }

    convenience init(feedRefreshController: FeedRefreshViewController) {
        self.init()
        self.feedRefreshController = feedRefreshController
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = feedRefreshController?.refreshControl
        tableView.prefetchDataSource = self
        feedRefreshController?.refresh()
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellControllers.count
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
        cellControllers[indexPath.row].cancel()
    }

    private func loadCellController(at indexPath: IndexPath) -> FeedImageCellController {
        return cellControllers[indexPath.row]
    }
}
