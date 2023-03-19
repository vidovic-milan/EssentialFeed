import UIKit
import EssentialFeed

public final class FeedUIComposer {
    private init() {}

    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedPresenter = FeedPresenter()
        let feedPresenterAdapter = FeedLoadingPresentationAdapter(feedLoader: feedLoader, presenter: feedPresenter)
        let refreshController = FeedRefreshViewController(loadFeed: feedPresenterAdapter.loadFeed)
        let controller = FeedViewController(feedRefreshController: refreshController)
        feedPresenter.feedLoadingView = WeakReferenceBox(object: refreshController)
        feedPresenter.feedView = FeedAdapter(controller: controller, imageLoader: imageLoader)
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

private class FeedAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader

    init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }

    func display(model: FeedViewModel) {
        controller?.cellControllers = model.feed.map { feedImage in
            let feedImageViewModel = FeedImageViewModel(model: feedImage, imageLoader: imageLoader, transformImage: UIImage.init)
            return FeedImageCellController(feedImageViewModel: feedImageViewModel)
        }
    }
}

private class FeedLoadingPresentationAdapter {
    private let feedLoader: FeedLoader
    private let presenter: FeedPresenter

    init(feedLoader: FeedLoader, presenter: FeedPresenter) {
        self.feedLoader = feedLoader
        self.presenter = presenter
    }

    func loadFeed() {
        presenter.didStartLoadingFeed()
        feedLoader.load { [weak self] result in
            switch result {
            case .success(let feed):
                self?.presenter.didLoadFeed(with: feed)
            case .failure(let error):
                self?.presenter.didFailLoadingFeed(with: error)
            }
        }
    }
}
