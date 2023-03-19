import UIKit
import EssentialFeed

public final class FeedUIComposer {
    private init() {}

    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedPresenter = FeedPresenter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(feedPresenter: feedPresenter)
        let controller = FeedViewController(feedRefreshController: refreshController)
        feedPresenter.feedLoadingView = refreshController
        feedPresenter.feedView = FeedAdapter(controller: controller, imageLoader: imageLoader)
        return controller
    }
}

private class FeedAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader

    init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }

    func display(feed: [FeedImage]) {
        controller?.cellControllers = feed.map { feedImage in
            let feedImageViewModel = FeedImageViewModel(model: feedImage, imageLoader: imageLoader, transformImage: UIImage.init)
            return FeedImageCellController(feedImageViewModel: feedImageViewModel)
        }
    }
}
