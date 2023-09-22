import UIKit
import EssentialFeed

public protocol FeedViewControllerDelegate {
    func didRequestFeedRefresh()
}

public final class FeedViewController: UITableViewController, FeedLoadingView, FeedErrorView, UITableViewDataSourcePrefetching {
    @IBOutlet private(set) public var errorView: ErrorView!

    public var delegate: FeedViewControllerDelegate?

    private var cellControllers = [FeedImageCellController]() {
        didSet { tableView.reloadData( )}
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        delegate?.didRequestFeedRefresh()
    }

    @IBAction private func refresh() {
        delegate?.didRequestFeedRefresh()
    }

    public func display(_ cellControllers: [FeedImageCellController]) {
        self.cellControllers = cellControllers
    }

    public func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }

    public func display(_ viewModel: FeedErrorViewModel) {
        if let errorMessage = viewModel.message {
            errorView.show(message: errorMessage)
        } else {
            errorView.hideMessage()
        }
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellControllers.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return loadCellController(at: indexPath).view(in: tableView)
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
