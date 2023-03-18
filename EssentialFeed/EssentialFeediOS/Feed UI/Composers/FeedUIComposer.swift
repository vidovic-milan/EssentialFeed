import UIKit
import EssentialFeed

public final class FeedUIComposer {
    private init() {}

    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        let controller = FeedViewController(feedRefreshController: refreshController)
        refreshController.onRefresh = adaptFeedToCellControllers(controller: controller, imageLoader: imageLoader)
        return controller
    }

    private static func adaptFeedToCellControllers(controller: FeedViewController, imageLoader: FeedImageDataLoader) -> (([FeedImage]) -> Void) {
        return { [weak controller] feed in
            controller?.cellControllers = feed.map { FeedImageCellController(model: $0, imageLoader: imageLoader) }
        }
    }
}
