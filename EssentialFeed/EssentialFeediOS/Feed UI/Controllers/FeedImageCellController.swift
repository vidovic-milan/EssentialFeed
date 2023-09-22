import UIKit
import EssentialFeed

public protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

public final class FeedImageCellController: FeedImageView {

    private var cell: FeedImageCell?
    private let delegate: FeedImageCellControllerDelegate

    public init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }

    func view(in tableView: UITableView) -> FeedImageCell {
        cell = tableView.dequeueCell()
        delegate.didRequestImage()

        return cell!
    }

    public func display(model: FeedImageViewModel<UIImage>) {
        cell?.locationLabel.text = model.location
        cell?.descriptionLabel.text = model.description
        cell?.locationContainer.isHidden = model.isLocationHidden
        cell?.feedImageView.setImageAnimated(model.loadedImage)
        cell?.retryButton.isHidden = !model.shouldRetry
        if model.isLoading {
            cell?.feedImageContainer.startShimmering()
        } else {
            cell?.feedImageContainer.stopShimmering()
        }
        cell?.onRetry = delegate.didRequestImage
    }

    func preload() {
        delegate.didRequestImage()
    }

    func cancel() {
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }

    private func releaseCellForReuse() {
        cell = nil
    }
}
