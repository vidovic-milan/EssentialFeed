import UIKit
import EssentialFeed

public protocol FeedImageLoaderDataTask {
    func cancel()
}

public protocol FeedImageLoader {
    func loadImage(from url: URL) -> FeedImageLoaderDataTask
}

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var feedLoader: FeedLoader?
    private var imageLoader: FeedImageLoader?
    private var loadTasks = [IndexPath: FeedImageLoaderDataTask]()
    private var feed = [FeedImage]()

    convenience public init(feedLoader: FeedLoader, imageLoader: FeedImageLoader) {
        self.init()
        self.feedLoader = feedLoader
        self.imageLoader = imageLoader
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadFeed), for: .valueChanged)
        tableView.prefetchDataSource = self
        loadFeed()
    }

    @objc private func loadFeed() {
        refreshControl?.beginRefreshing()
        feedLoader?.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feed = feed
                self?.tableView.reloadData()
            }
            self?.refreshControl?.endRefreshing()
        }
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
        let task = imageLoader?.loadImage(from: model.url)
        loadTasks[indexPath] = task
        return cell
    }

    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        loadTasks[indexPath]?.cancel()
    }

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let model = feed[indexPath.row]
            let task = imageLoader?.loadImage(from: model.url)
            loadTasks[indexPath] = task
        }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            loadTasks[indexPath]?.cancel()
        }
    }
}
