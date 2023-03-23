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

    init(feedImageView: View) {
        self.feedImageView = feedImageView
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

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter<ImageStub, FeedImageViewSpy>, view: FeedImageViewSpy) {
        let view = FeedImageViewSpy()
        let sut = FeedImagePresenter(feedImageView: view)
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
}

extension FeedImageViewModel: Equatable where Image: Equatable {}
