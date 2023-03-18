import UIKit
import EssentialFeed

final class FeedCellViewController {
    private var loadTask: FeedImageLoaderDataTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader

    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }

    func view() -> FeedImageCell {
        let cell = FeedImageCell()
        cell.locationLabel.text = model.location
        cell.descriptionLabel.text = model.description
        cell.locationContainer.isHidden = model.location == nil
        cell.retryButton.isHidden = true
        cell.feedImageView.image = nil
        cell.feedImageContainer.startShimmering()
        let loadImage = { [weak self, cell] in
            guard let self = self else { return }
            let task = self.imageLoader.loadImage(from: self.model.url) { [weak cell] result in
                let imageData = try? result.get()
                let image = imageData.map(UIImage.init) ?? nil
                cell?.retryButton.isHidden = image != nil
                cell?.feedImageView.image = image
                cell?.feedImageContainer.stopShimmering()
            }
            self.loadTask = task
        }
        cell.onRetry = loadImage
        loadImage()

        return cell
    }

    func preload() {
        let task = imageLoader.loadImage(from: model.url) { _ in }
        loadTask = task
    }

    func cancel() {
        loadTask?.cancel()
        loadTask = nil
    }
}

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var imageLoader: FeedImageDataLoader?
    private var feedRefreshController: FeedRefreshViewController?
    private var feedCellViewControllers = [IndexPath: FeedCellViewController]()
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
        feedCellViewControllers[indexPath]?.cancel()
    }

    private func loadCellController(at indexPath: IndexPath) -> FeedCellViewController {
        let model = feed[indexPath.row]
        let cellController = FeedCellViewController(model: model, imageLoader: imageLoader!)
        feedCellViewControllers[indexPath] = cellController

        return cellController
    }
}
