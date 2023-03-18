import EssentialFeed
import UIKit

final class FeedImageCellController {
    private var loadTask: FeedImageLoaderDataTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader

    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }

    func view() -> FeedImageCell {
        let cell = FeedImageCell()
        cell.locationLabel.text = model.location
        cell.descriptionLabel.text = model.description
        cell.locationContainer.isHidden = model.location == nil
        cell.retryButton.isHidden = true
        cell.feedImageView.image = nil
        cell.feedImageContainer.startShimmering()
        let loadImage = { [weak self, cell] in
            guard let self = self else { return }
            let task = self.imageLoader.loadImage(from: self.model.url) { [weak cell] result in
                let imageData = try? result.get()
                let image = imageData.map(UIImage.init) ?? nil
                cell?.retryButton.isHidden = image != nil
                cell?.feedImageView.image = image
                cell?.feedImageContainer.stopShimmering()
            }
            self.loadTask = task
        }
        cell.onRetry = loadImage
        loadImage()

        return cell
    }

    func preload() {
        let task = imageLoader.loadImage(from: model.url) { _ in }
        loadTask = task
    }

    func cancel() {
        loadTask?.cancel()
        loadTask = nil
    }
}
