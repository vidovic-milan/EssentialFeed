import Foundation
import EssentialFeed

protocol FeedImageView {
    associatedtype Image

    func display(model: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<Image, View: FeedImageView> where Image == View.Image {

    private let feedImageView: View
    private let transformImage: (Data) -> Image?

    init(feedImageView: View, transformImage: @escaping (Data) -> Image?) {
        self.feedImageView = feedImageView
        self.transformImage = transformImage
    }

    func didStartLoadingImage(for model: FeedImage) {
        let viewModel = FeedImageViewModel<Image>(
            location: model.location,
            description: model.description,
            isLocationHidden: model.location == nil,
            loadedImage: nil,
            shouldRetry: false,
            isLoading: true
        )
        feedImageView.display(model: viewModel)
    }

    private struct InvalidImageDataError: Error {}

    func didFinishLoading(with imageData: Data, for model: FeedImage) {
        guard let image = transformImage(imageData) else {
            return didFinishLoading(with: InvalidImageDataError(), for: model)
        }

        let viewModel = FeedImageViewModel<Image>(
            location: model.location,
            description: model.description,
            isLocationHidden: model.location == nil,
            loadedImage: image,
            shouldRetry: false,
            isLoading: false
        )
        feedImageView.display(model: viewModel)
    }

    func didFinishLoading(with error: Error, for model: FeedImage) {
        let viewModel = FeedImageViewModel<Image>(
            location: model.location,
            description: model.description,
            isLocationHidden: model.location == nil,
            loadedImage: nil,
            shouldRetry: true,
            isLoading: false
        )
        feedImageView.display(model: viewModel)
    }
}
