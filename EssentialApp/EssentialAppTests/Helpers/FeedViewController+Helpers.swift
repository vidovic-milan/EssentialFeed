import EssentialFeediOS
import UIKit

extension FeedImageCell {
    var descriptionText: String? {
        return descriptionLabel.text
    }

    var locationText: String? {
        return locationLabel.text
    }

    var isShowingLocation: Bool {
        return locationContainer.isHidden == false
    }

    var isShimmeringAnimationVisible: Bool {
        return feedImageContainer.layer.mask != nil
    }

    var renderedImage: Data? {
        return feedImageView.image?.pngData()
    }

    var isRetryButtonVisible: Bool {
        return !retryButton.isHidden
    }

    func retryButtonTap() {
        retryButton.allTargets.forEach { target in
            retryButton.actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach { action in
                (target as NSObject).perform(Selector(action))
            }
        }
    }
}

extension FeedViewController {
    var numberOfVisibleFeedViews: Int {
        tableView.numberOfRows(inSection: feedSection)
    }

    private var feedSection: Int {
        return 0
    }

    var errorMessage: String? {
        errorView.message
    }

    var isLoadingIndicatorVisible: Bool {
        refreshControl?.isRefreshing == true
    }

    func feedImageView(at index: Int) -> FeedImageCell? {
        tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: index, section: feedSection)) as? FeedImageCell
    }

    @discardableResult
    func simulateFeedImageVisible(at index: Int) -> FeedImageCell? {
        feedImageView(at: index)
    }

    @discardableResult
    func simulateFeedImageNotVisible(at index: Int) -> FeedImageCell? {
        let cell = feedImageView(at: index)
        tableView.delegate?.tableView?(tableView, didEndDisplaying: cell!, forRowAt: IndexPath(row: index, section: feedSection))
        return cell
    }

    func simulateFeedImageJustBeforeDisplaying(at index: Int) {
        let cell = FeedImageCell()
        tableView.delegate?.tableView?(tableView, willDisplay: cell, forRowAt: IndexPath(row: index, section: feedSection))
    }

    func simulateFeedImageNearVisible(at index: Int) {
        tableView.prefetchDataSource?.tableView(tableView, prefetchRowsAt: [IndexPath(row: index, section: feedSection)])
    }

    func simulateFeedImageNotNearVisible(at index: Int) {
        simulateFeedImageNearVisible(at: index)
        tableView.prefetchDataSource?.tableView?(tableView, cancelPrefetchingForRowsAt: [IndexPath(row: index, section: feedSection)])
    }

    func simulateUserInitiatedFeedLoad() {
        refreshControl?.simulatePullToRefresh()
    }

    func simulateTapOnErrorMessage() {
        errorView.button.simulateTap()
    }

    func renderedFeedImageData(at index: Int) -> Data? {
        return simulateFeedImageVisible(at: index)?.renderedImage
    }
}

extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                (target as NSObject).perform(Selector(action))
            }
        }
    }
}

extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach { action in
                (target as NSObject).perform(Selector(action))
            }
        }
    }
}
    

extension UIImage {
    static func make(from color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        return UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
            color.setFill()
            rendererContext.fill(rect)
        }
    }
}
