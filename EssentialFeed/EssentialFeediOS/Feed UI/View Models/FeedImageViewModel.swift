import Foundation
import EssentialFeed

final class FeedImageViewModel<Image> {
    typealias Observer<T> = (T) -> Void
    private var loadTask: FeedImageLoaderDataTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private let transformImage: (Data) -> Image?

    init(model: FeedImage, imageLoader: FeedImageDataLoader, transformImage: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.transformImage = transformImage
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

    var onLoadedImage: Observer<Image?>?
    func loadImage() {
        let transformImage = self.transformImage
        loadTask = imageLoader.loadImage(from: model.url) { [weak self] result in
            let imageData = try? result.get()
            let image = imageData.map(transformImage) ?? nil
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
