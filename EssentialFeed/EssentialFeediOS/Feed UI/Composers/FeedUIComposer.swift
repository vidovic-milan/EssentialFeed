import UIKit
import EssentialFeed

public final class FeedUIComposer {
    private init() {}

    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedPresenterAdapter = FeedLoadingPresentationAdapter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(feedRefreshDelegate: feedPresenterAdapter)
        let controller = FeedViewController(feedRefreshController: refreshController)
        let feedPresenter = FeedPresenter(feedLoadingView: WeakReferenceBox(object: refreshController), feedView: FeedAdapter(controller: controller, imageLoader: imageLoader))
        feedPresenterAdapter.presenter = feedPresenter
        return controller
    }
}

private class WeakReferenceBox<T: AnyObject> {
    private weak var object: T?

    init(object: T?) {
        self.object = object
    }
}

extension WeakReferenceBox: FeedLoadingView where T: FeedLoadingView {
    func display(model: FeedLoadingViewModel) {
        object?.display(model: model)
    }
}

extension WeakReferenceBox: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(model: FeedImageViewModel<UIImage>) {
        object?.display(model: model)
    }
}

private class FeedAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader

    init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }

    func display(model: FeedViewModel) {
        controller?.cellControllers = model.feed.map { feedImage in
            let feedImagePresenter = FeedImagePresenter<UIImage, WeakReferenceBox<FeedImageCellController>>(transformImage: UIImage.init)
            let feedImageAdapter = FeedImagePresentationAdapter(model: feedImage, presenter: feedImagePresenter, imageLoader: imageLoader)
            let controller = FeedImageCellController(loadImage: feedImageAdapter.loadImage, preload: feedImageAdapter.preload, cancel: feedImageAdapter.cancel)
            feedImagePresenter.feedImageView = WeakReferenceBox(object: controller)
            return controller
        }
    }
}

private class FeedLoadingPresentationAdapter: FeedRefreshViewControllerDelegate {
    private let feedLoader: FeedLoader
    var presenter: FeedPresenter?

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        feedLoader.load { [weak self] result in
            switch result {
            case .success(let feed):
                self?.presenter?.didLoadFeed(with: feed)
            case .failure(let error):
                self?.presenter?.didFailLoadingFeed(with: error)
            }
        }
    }
}

private class FeedImagePresentationAdapter<Image, View: FeedImageView> where Image == View.Image {
    private var loadTask: FeedImageLoaderDataTask?
    private let model: FeedImage
    private let presenter: FeedImagePresenter<Image, View>
    private let imageLoader: FeedImageDataLoader

    init(model: FeedImage, presenter: FeedImagePresenter<Image, View>, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.presenter = presenter
        self.imageLoader = imageLoader
    }

    func loadImage() {
        presenter.didStartLoadingImage(for: model)
        loadTask = imageLoader.loadImage(from: model.url) { [weak self] result in
            self?.handleResult(result)
        }
    }

    private func handleResult(_ result: Result<Data, Error>) {
        let imageData = try? result.get()
        presenter.didFinishLoading(with: imageData, for: model)
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
