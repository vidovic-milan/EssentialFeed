import UIKit
import EssentialFeed
import EssentialFeediOS

public final class FeedUIComposer {
    private init() {}

    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedPresenterAdapter = FeedLoadingPresentationAdapter(feedLoader: MainQueueDispatchDecorator(decoratee: feedLoader))
        let controller = FeedViewController.make(delegate: feedPresenterAdapter, title: FeedPresenter.title)
        let feedAdapter = FeedAdapter(controller: controller, imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader))
        let weakController = WeakReferenceBox(object: controller)
        let feedPresenter = FeedPresenter(feedView: feedAdapter, loadingView: weakController, errorView: weakController)
        feedPresenterAdapter.presenter = feedPresenter
        return controller
    }
}

private extension FeedViewController {
    static func make(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! FeedViewController
        controller.delegate = delegate
        controller.title = title
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
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakReferenceBox: FeedErrorView where T: FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel) {
        object?.display(viewModel)
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

    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { feedImage in
            let adapter = FeedImagePresentationAdapter<UIImage, WeakReferenceBox<FeedImageCellController>>(model: feedImage, imageLoader: imageLoader)
            let view = FeedImageCellController(delegate: adapter)
            let presenter = FeedImagePresenter(feedImageView: WeakReferenceBox(object: view), transformImage: UIImage.init)
            adapter.presenter = presenter
            return view
        })
    }
}

private class FeedLoadingPresentationAdapter: FeedViewControllerDelegate {
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
                self?.presenter?.didFinishLoadingFeed(with: feed)
            case .failure(let error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}

private class FeedImagePresentationAdapter<Image, View: FeedImageView>: FeedImageCellControllerDelegate where Image == View.Image {
    private var loadTask: FeedImageLoaderDataTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader

    var presenter: FeedImagePresenter<Image, View>?

    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }

    func didRequestImage() {
        presenter?.didStartLoadingImage(for: model)
        loadTask = imageLoader.loadImage(from: model.url) { [weak self] result in
            self?.handleResult(result)
        }
    }

    private func handleResult(_ result: Result<Data, Error>) {
        switch result {
        case .success(let data):
            presenter?.didFinishLoading(with: data, for: model)
        case .failure(let error):
            presenter?.didFinishLoading(with: error, for: model)
        }
    }

    func didCancelImageRequest() {
        loadTask?.cancel()
        loadTask = nil
    }
}
