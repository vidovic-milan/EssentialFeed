import UIKit
import EssentialFeed

public final class FeedUIComposer {
    private init() {}

    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedViewModel = FeedViewModel(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(feedViewModel: feedViewModel)
        let controller = FeedViewController(feedRefreshController: refreshController)
        feedViewModel.onLoad = adaptFeedToCellControllers(controller: controller, imageLoader: imageLoader)
        return controller
    }

    private static func adaptFeedToCellControllers(controller: FeedViewController, imageLoader: FeedImageDataLoader) -> (([FeedImage]) -> Void) {
        return { [weak controller] feed in
            controller?.cellControllers = feed.map { FeedImageCellController(model: $0, imageLoader: imageLoader) }
        }
    }
}
