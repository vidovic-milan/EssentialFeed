import UIKit

protocol FeedImageCellControllerDelegate {
    func didRequestImageLoading()
    func didRequestImagePreloading()
    func didRequestImageLoadingCancellation()
}

final class FeedImageCellController: FeedImageView {

    private weak var cell: FeedImageCell?
    private let delegate: FeedImageCellControllerDelegate

    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }

    func view() -> FeedImageCell {
        let cell = FeedImageCell()
        self.cell = cell
        delegate.didRequestImageLoading()

        return cell
    }

    func display(model: FeedImageViewModel<UIImage>) {
        cell?.locationLabel.text = model.location
        cell?.descriptionLabel.text = model.description
        cell?.locationContainer.isHidden = model.isLocationHidden
        cell?.feedImageView.image = model.loadedImage
        cell?.retryButton.isHidden = !model.shouldRetry
        if model.isLoading {
            cell?.feedImageContainer.startShimmering()
        } else {
            cell?.feedImageContainer.stopShimmering()
        }
        cell?.onRetry = { [weak self] in
            self?.delegate.didRequestImageLoading()
        }
    }

    func preload() {
        delegate.didRequestImagePreloading()
    }

    func cancel() {
        delegate.didRequestImageLoadingCancellation()
    }
}
