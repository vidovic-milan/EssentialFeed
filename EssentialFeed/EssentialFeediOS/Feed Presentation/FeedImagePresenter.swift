import Foundation
import EssentialFeed

struct FeedImageViewModel<Image> {
    let location: String?
    let description: String?
    let isLocationHidden: Bool
    let loadedImage: Image?
    let shouldRetry: Bool
    let isLoading: Bool
}

protocol FeedImageView {
    associatedtype Image

    func display(model: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<Image, View: FeedImageView> where Image == View.Image {

    private let transformImage: (Data) -> Image?

    var feedImageView: View?

    init(transformImage: @escaping (Data) -> Image?) {
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
        feedImageView?.display(model: viewModel)
    }

    func didFinishLoading(with imageData: Data?, for model: FeedImage) {
        let image = imageData.flatMap(transformImage)
        let viewModel = FeedImageViewModel<Image>(
            location: model.location,
            description: model.description,
            isLocationHidden: model.location == nil,
            loadedImage: image,
            shouldRetry: image == nil,
            isLoading: false
        )
        feedImageView?.display(model: viewModel)
    }
}
