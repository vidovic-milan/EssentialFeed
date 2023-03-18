import EssentialFeed
import UIKit

final class FeedImageViewModel {
    private var loadTask: FeedImageLoaderDataTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader

    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }

    var location: String? {
        return model.location
    }

    var description: String? {
        return model.description
    }

    var isLocationHidden: Bool {
        return model.location == nil
    }

    var onLoadedImage: ((UIImage?) -> Void)?
    func loadImage() {
        loadTask = self.imageLoader.loadImage(from: model.url) { [weak self] result in
            let imageData = try? result.get()
            let image = imageData.map(UIImage.init) ?? nil
            self?.onLoadedImage?(image)
        }
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

final class FeedImageCellController {
    private let viewModel: FeedImageViewModel

    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.viewModel = FeedImageViewModel(model: model, imageLoader: imageLoader)
    }

    func view() -> FeedImageCell {
        let cell = FeedImageCell()
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        cell.locationContainer.isHidden = viewModel.isLocationHidden
        cell.retryButton.isHidden = true
        cell.feedImageView.image = nil
        cell.feedImageContainer.startShimmering()
        viewModel.onLoadedImage = { [weak cell] image in
            cell?.retryButton.isHidden = image != nil
            cell?.feedImageView.image = image
            cell?.feedImageContainer.stopShimmering()
        }
        cell.onRetry = { [weak viewModel] in
            viewModel?.loadImage()
        }
        viewModel.loadImage()

        return cell
    }

    func preload() {
        viewModel.preload()
    }

    func cancel() {
        viewModel.cancel()
    }
}
