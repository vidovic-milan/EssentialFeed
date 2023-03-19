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
