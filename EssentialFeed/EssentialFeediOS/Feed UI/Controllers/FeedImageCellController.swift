import UIKit

final class FeedImageCellController: FeedImageView {

    private weak var cell: FeedImageCell?
    private let loadImage: () -> Void
    private let preloadImage: () -> Void
    private let cancelImageLoading: () -> Void

    init(loadImage: @escaping () -> Void, preload: @escaping () -> Void, cancel: @escaping () -> Void) {
        self.loadImage = loadImage
        self.preloadImage = preload
        self.cancelImageLoading = cancel
    }

    func view() -> FeedImageCell {
        let cell = FeedImageCell()
        self.cell = cell
        loadImage()

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
            self?.loadImage()
        }
    }

    func preload() {
        preloadImage()
    }

    func cancel() {
        cancelImageLoading()
    }
}
