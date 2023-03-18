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
