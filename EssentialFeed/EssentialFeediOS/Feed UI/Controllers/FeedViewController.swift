import UIKit
import EssentialFeed

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var imageLoader: FeedImageDataLoader?
    private var feedRefreshController: FeedRefreshViewController?
    private var loadTasks = [IndexPath: FeedImageLoaderDataTask]()
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
        let model = feed[indexPath.row]
        let cell = FeedImageCell()
        cell.locationLabel.text = model.location
        cell.descriptionLabel.text = model.description
        cell.locationContainer.isHidden = model.location == nil
        cell.retryButton.isHidden = true
        cell.feedImageView.image = nil
        cell.feedImageContainer.startShimmering()
        let loadImage = { [weak self, cell] in
            let task = self?.imageLoader?.loadImage(from: model.url) { [weak cell] result in
                let imageData = try? result.get()
                let image = imageData.map(UIImage.init) ?? nil
                cell?.retryButton.isHidden = image != nil
                cell?.feedImageView.image = image
                cell?.feedImageContainer.stopShimmering()
            }
            self?.loadTasks[indexPath] = task
        }
        cell.onRetry = loadImage
        loadImage()

        return cell
    }

    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        startTask(at: indexPath)
    }

    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelTask(at: indexPath)
    }

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { startTask(at: $0) }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { cancelTask(at: $0) }
    }

    private func cancelTask(at indexPath: IndexPath) {
        loadTasks[indexPath]?.cancel()
        loadTasks[indexPath] = nil
    }

    private func startTask(at indexPath: IndexPath) {
        let model = feed[indexPath.row]
        let task = imageLoader?.loadImage(from: model.url, completion: { _ in })
        loadTasks[indexPath] = task
    }
}
