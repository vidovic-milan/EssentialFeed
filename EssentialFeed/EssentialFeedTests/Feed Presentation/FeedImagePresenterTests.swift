import XCTest
import EssentialFeed

final class FeedImagePresenterTests: XCTestCase {
    func test_init_doesNotMessageViewUponCreation() {
        let (_ , view) = makeSUT()

        XCTAssertEqual(view.messages.count, 0)
    }

    func test_didStartLoadingImage_displayLoadingState() {
        let (sut , view) = makeSUT()

        let feedImage = anyFeedImage()
        sut.didStartLoadingImage(for: feedImage)

        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, feedImage.description)
        XCTAssertEqual(message?.location, feedImage.location)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertNil(message?.loadedImage)
    }

    func test_didFinishLoadingWithImageData_displayLoadedImageState() {
        let loadedImage = ImageStub()
        let feedImage = anyFeedImage()
        let (sut , view) = makeSUT(transformImage: { _ in return loadedImage })

        sut.didFinishLoading(with: Data(), for: feedImage)

        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, feedImage.description)
        XCTAssertEqual(message?.location, feedImage.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertEqual(message?.loadedImage, loadedImage)
    }

    func test_didFinishLoadingWithInvalidImageData_displayErrorState() {
        let (sut , view) = makeSUT(transformImage: { _ in return nil })

        let feedImage = anyFeedImage()
        sut.didFinishLoading(with: Data(), for: feedImage)

        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, feedImage.description)
        XCTAssertEqual(message?.location, feedImage.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.loadedImage)
    }

    func test_didFinishLoadingWithError_displayLoadedImageState() {
        let (sut , view) = makeSUT()

        let feedImage = anyFeedImage()
        sut.didFinishLoading(with: NSError(domain: "", code: 1), for: feedImage)

        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, feedImage.description)
        XCTAssertEqual(message?.location, feedImage.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.loadedImage)
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

    private struct ImageStub: Equatable {}

    private class FeedImageViewSpy: FeedImageView {
        var messages: [FeedImageViewModel<ImageStub>] = []
        func display(model: FeedImageViewModel<ImageStub>) {
            messages.append(model)
        }
    }

    private func anyFeedImage() -> FeedImage {
        return FeedImage(id: UUID(), description: nil, location: nil, url: URL(string: "https://a-url.com")!)
    }
}
