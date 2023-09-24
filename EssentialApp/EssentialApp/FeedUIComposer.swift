import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

public final class FeedUIComposer {
    private init() {}

    public static func feedComposedWith(
        feedLoader: @escaping () -> FeedLoader.Publisher,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher
    ) -> FeedViewController {
        let feedPresenterAdapter = FeedLoadingPresentationAdapter(feedLoader: feedLoader)
        let controller = FeedViewController.make(delegate: feedPresenterAdapter, title: FeedPresenter.title)
        let feedAdapter = FeedAdapter(controller: controller, imageLoader: imageLoader)
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
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher

    init(controller: FeedViewController, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
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
    private let feedLoader: () -> FeedLoader.Publisher
    private var cancellable: Cancellable?
    var presenter: FeedPresenter?

    init(feedLoader: @escaping () -> FeedLoader.Publisher) {
        self.feedLoader = feedLoader
    }

    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()

        cancellable = feedLoader()
            .dispatchOnMainQueue()
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished: break
                        
                    case let .failure(error):
                        self?.presenter?.didFinishLoadingFeed(with: error)
                    }
                }, receiveValue: { [weak self] feed in
                    self?.presenter?.didFinishLoadingFeed(with: feed)
                })
    }
}

private class FeedImagePresentationAdapter<Image, View: FeedImageView>: FeedImageCellControllerDelegate where Image == View.Image {
    private var loadTask: FeedImageLoaderDataTask?
    private let model: FeedImage
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    private var cancellable: Cancellable?

    var presenter: FeedImagePresenter<Image, View>?

    init(model: FeedImage, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.model = model
        self.imageLoader = imageLoader
    }

    func didRequestImage() {
        presenter?.didStartLoadingImage(for: model)
        let model = self.model
        cancellable = imageLoader(model.url)
            .dispatchOnMainQueue()
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished: break
                        
                    case let .failure(error):
                        self?.presenter?.didFinishLoading(with: error, for: model)
                    }
                    
                }, receiveValue: { [weak self] data in
                    self?.presenter?.didFinishLoading(with: data, for: model)
                })
    }

    func didCancelImageRequest() {
        cancellable?.cancel()
        cancellable = nil
    }
}
