import XCTest
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

final class FeedImagePresenterTests: XCTestCase {
    func test_init_doesNotMessageViewUponCreation() {
        let (_ , view) = makeSUT()

        XCTAssertEqual(view.messages, [])
    }

    func test_didStartLoadingImage_displayLoadingState() {
        let (sut , view) = makeSUT()

        let feedImage = anyFeedImage()
        sut.didStartLoadingImage(for: feedImage)

        XCTAssertEqual(view.messages, [loadingStateModel(for: feedImage)])
    }

    func test_didFinishLoadingWithImageData_displayLoadedImageState() {
        let loadedImage = ImageStub()
        let feedImage = anyFeedImage()
        let (sut , view) = makeSUT(transformImage: { _ in return loadedImage })

        sut.didFinishLoading(with: Data(), for: feedImage)

        XCTAssertEqual(view.messages, [loadedImageStateModel(for: feedImage, loadedImage: loadedImage)])
    }

    func test_didFinishLoadingWithInvalidImageData_displayErrorState() {
        let (sut , view) = makeSUT(transformImage: { _ in return nil })

        let feedImage = anyFeedImage()
        sut.didFinishLoading(with: Data(), for: feedImage)

        XCTAssertEqual(view.messages, [errorStateModel(for: feedImage)])
    }

    func test_didFinishLoadingWithError_displayLoadedImageState() {
        let (sut , view) = makeSUT()

        let feedImage = anyFeedImage()
        sut.didFinishLoading(with: NSError(domain: "", code: 1), for: feedImage)

        XCTAssertEqual(view.messages, [errorStateModel(for: feedImage)])
    }

    // MARK: - Helpers

    private func makeSUT(
        transformImage: @escaping (Data) -> ImageStub? = { _ in return nil },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: FeedImagePresenter<ImageStub, FeedImageViewSpy>, view: FeedImageViewSpy) {
        let view = FeedImageViewSpy()
        let sut = FeedImagePresenter(feedImageView: view, transformImage: transformImage)
        trackForMemoryLeaks(view)
        trackForMemoryLeaks(sut)
        return (sut, view)
    }

    private class ImageStub: Equatable {
        static func == (lhs: FeedImagePresenterTests.ImageStub, rhs: FeedImagePresenterTests.ImageStub) -> Bool {
            lhs === rhs
        }
    }

    private class FeedImageViewSpy: FeedImageView {
        var messages: [FeedImageViewModel<ImageStub>] = []
        func display(model: FeedImageViewModel<ImageStub>) {
            messages.append(model)
        }
    }

    private func anyFeedImage() -> FeedImage {
        return FeedImage(id: UUID(), description: nil, location: nil, url: URL(string: "https://a-url.com")!)
    }

    private func loadingStateModel(for model: FeedImage) -> FeedImageViewModel<ImageStub> {
        return FeedImageViewModel<ImageStub>(
            location: model.location,
            description: model.description,
            isLocationHidden: model.location == nil,
            loadedImage: nil,
            shouldRetry: false,
            isLoading: true
        )
    }

    private func loadedImageStateModel(for model: FeedImage, loadedImage: ImageStub) -> FeedImageViewModel<ImageStub> {
        return FeedImageViewModel<ImageStub>(
            location: model.location,
            description: model.description,
            isLocationHidden: model.location == nil,
            loadedImage: loadedImage,
            shouldRetry: false,
            isLoading: false
        )
    }

    private func errorStateModel(for model: FeedImage) -> FeedImageViewModel<ImageStub> {
        return FeedImageViewModel<ImageStub>(
            location: model.location,
            description: model.description,
            isLocationHidden: model.location == nil,
            loadedImage: nil,
            shouldRetry: true,
            isLoading: false
        )
    }
}

extension FeedImageViewModel: Equatable where Image: Equatable {}
