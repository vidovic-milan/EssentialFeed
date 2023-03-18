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

    var onLoadedImage: Observer<Image>?
    var onShouldRetryChange: Observer<Bool>?
    var onLoadingChange: Observer<Bool>?

    func loadImage() {
        onShouldRetryChange?(false)
        onLoadingChange?(true)
        loadTask = imageLoader.loadImage(from: model.url) { [weak self] result in
            self?.handleResult(result)
        }
    }

    private func handleResult(_ result: Result<Data, Error>) {
        let imageData = (try? result.get()).flatMap(transformImage)
        if let image = imageData {
            onLoadedImage?(image)
        } else {
            onShouldRetryChange?(true)
        }
        onLoadingChange?(false)
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
