import XCTest
import EssentialFeed
import EssentialFeediOS
import EssentialApp

class FeedUIIntegrationTests: XCTestCase {

    func test_view_hasTitleWhenLoaded() {
        let (sut, _) = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.title, localized("FEED_VIEW_TITLE"))
    }

    func test_loadFeedAction_requestsFeedFromLoader() {
        let (sut, loader) = makeSUT()

        XCTAssertEqual(loader.loadCallCount, 0)

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1)

        sut.simulateUserInitiatedFeedLoad()
        XCTAssertEqual(loader.loadCallCount, 2)

        sut.simulateUserInitiatedFeedLoad()
        XCTAssertEqual(loader.loadCallCount, 3)
    }

    func test_loadingFeedIndicator_isVisibleWhenLoadingFeed() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.isLoadingIndicatorVisible, true)

        loader.completeLoading(at: 0)
        XCTAssertEqual(sut.isLoadingIndicatorVisible, false)

        sut.simulateUserInitiatedFeedLoad()
        XCTAssertEqual(sut.isLoadingIndicatorVisible, true)

        sut.simulateUserInitiatedFeedLoad()
        loader.completeLoadingWithError(at: 1)
        XCTAssertEqual(sut.isLoadingIndicatorVisible, false)
    }

    func test_loadFeedCompletion_rendersImagesSuccessfully() {
        let image0 = makeFeedImage(description: "a desc", location: "a loc")
        let image1 = makeFeedImage(description: nil, location: "a loc")
        let image2 = makeFeedImage(description: "a desc", location: nil)
        let image3 = makeFeedImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        assertThat(sut, hasDisplayed: [])

        loader.completeLoading(with: [image0], at: 0)
        assertThat(sut, hasDisplayed: [image0])

        sut.simulateUserInitiatedFeedLoad()
        loader.completeLoading(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, hasDisplayed: [image0, image1, image2, image3])
    }

    func test_loadFeedCompletion_rendersSuccessfullyLoadedEmptyFeedAfterNonEmptyFeed() {
        let image0 = makeFeedImage()
        let image1 = makeFeedImage()
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image0, image1], at: 0)
        assertThat(sut, hasDisplayed: [image0, image1])

        sut.simulateUserInitiatedFeedLoad()
        loader.completeLoading(with: [], at: 1)
        assertThat(sut, hasDisplayed: [])
    }

    func test_loadFeedCompletion_doesNotAlterCurrentImages() {
        let image0 = makeFeedImage(description: "a desc", location: "a loc")
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image0], at: 0)
        assertThat(sut, hasDisplayed: [image0])

        sut.simulateUserInitiatedFeedLoad()
        loader.completeLoadingWithError(at: 1)
        assertThat(sut, hasDisplayed: [image0])
    }

    func test_feedImageView_loadsImageURLsWhenVisible() {
        let url0 = URL(string: "https://image0.com")!
        let url1 = URL(string: "https://image1.com")!
        let image0 = makeFeedImage(url: url0)
        let image1 = makeFeedImage(url: url1)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image0, image1], at: 0)

        XCTAssertEqual(loader.loadImageURLs, [])

        sut.simulateFeedImageVisible(at: 0)
        XCTAssertEqual(loader.loadImageURLs, [url0])

        sut.simulateFeedImageVisible(at: 1)
        XCTAssertEqual(loader.loadImageURLs, [url0, url1])
    }

    func test_feedImageView_cancelsLoadingWhenNotVisibleAnymore() {
        let url0 = URL(string: "https://image0.com")!
        let url1 = URL(string: "https://image1.com")!
        let image0 = makeFeedImage(url: url0)
        let image1 = makeFeedImage(url: url1)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image0, image1], at: 0)

        XCTAssertEqual(loader.loadImageURLs, [])

        sut.simulateFeedImageNotVisible(at: 0)
        XCTAssertEqual(loader.cancelLoadingURLs, [url0])

        sut.simulateFeedImageNotVisible(at: 1)
        XCTAssertEqual(loader.cancelLoadingURLs, [url0, url1])
    }

    func test_feedImageView_displaysLoadingIndicatornWhileLoadingImage() {
        let url0 = URL(string: "https://image0.com")!
        let url1 = URL(string: "https://image1.com")!
        let image0 = makeFeedImage(url: url0)
        let image1 = makeFeedImage(url: url1)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image0, image1], at: 0)

        let view0 = sut.feedImageView(at: 0)
        XCTAssertTrue(view0?.isShimmeringAnimationVisible == true)

        let view1 = sut.feedImageView(at: 1)
        XCTAssertTrue(view1?.isShimmeringAnimationVisible == true)
    }

    func test_feedImageView_stopsLoadingIndicatorWhileLoadingImageIsCompleted() {
        let url0 = URL(string: "https://image0.com")!
        let url1 = URL(string: "https://image1.com")!
        let image0 = makeFeedImage(url: url0)
        let image1 = makeFeedImage(url: url1)
        let imageData = UIImage.make(from: .red).pngData()!
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image0, image1], at: 0)

        let view0 = sut.feedImageView(at: 0)
        loader.completeLoadingImage(with: imageData, at: 0)
        XCTAssertFalse(view0?.isShimmeringAnimationVisible == true)

        let view1 = sut.feedImageView(at: 1)
        loader.completeLoadingImageWithError(at: 1)
        XCTAssertFalse(view1?.isShimmeringAnimationVisible == true)
    }

    func test_feedImageView_rendersImageLoadedFromUrl() {
        let url0 = URL(string: "https://image0.com")!
        let url1 = URL(string: "https://image1.com")!
        let image0 = makeFeedImage(url: url0)
        let image1 = makeFeedImage(url: url1)
        let imageData = UIImage.make(from: .red).pngData()!
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image0, image1], at: 0)

        let view0 = sut.feedImageView(at: 0)
        loader.completeLoadingImage(with: imageData, at: 0)
        XCTAssertEqual(view0?.renderedImage, imageData)

        let view1 = sut.feedImageView(at: 1)
        loader.completeLoadingImageWithError(at: 1)
        XCTAssertEqual(view1?.renderedImage, .none)
    }

    func test_feedImageViewRetryButton_isVisibleWhenLoadingImageFails() {
        let url0 = URL(string: "https://image0.com")!
        let url1 = URL(string: "https://image1.com")!
        let image0 = makeFeedImage(url: url0)
        let image1 = makeFeedImage(url: url1)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image0, image1], at: 0)

        let view0 = sut.feedImageView(at: 0)
        XCTAssertTrue(view0?.isRetryButtonVisible == false)

        loader.completeLoadingImageWithError(at: 0)
        XCTAssertTrue(view0?.isRetryButtonVisible == true)

        let view1 = sut.feedImageView(at: 1)
        XCTAssertTrue(view1?.isRetryButtonVisible == false)

        loader.completeLoadingImage(with: Data("invalid".utf8), at: 1)
        XCTAssertTrue(view1?.isRetryButtonVisible == true)
    }

    func test_feedImageViewRetryButton_retryLoadingImageOnTap() {
        let url0 = URL(string: "https://image0.com")!
        let url1 = URL(string: "https://image1.com")!
        let image0 = makeFeedImage(url: url0)
        let image1 = makeFeedImage(url: url1)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.loadImageURLs, [])

        let view0 = sut.feedImageView(at: 0)
        XCTAssertEqual(loader.loadImageURLs, [url0])

        view0?.retryButtonTap()
        XCTAssertEqual(loader.loadImageURLs, [url0, url0])

        let view1 = sut.feedImageView(at: 1)
        XCTAssertEqual(loader.loadImageURLs, [url0, url0, url1])

        view1?.retryButtonTap()
        XCTAssertEqual(loader.loadImageURLs, [url0, url0, url1, url1])
    }

    func test_feedImageView_loadsImageURLsWhenFeedIsNearVisible() {
        let url0 = URL(string: "https://image0.com")!
        let url1 = URL(string: "https://image1.com")!
        let image0 = makeFeedImage(url: url0)
        let image1 = makeFeedImage(url: url1)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.loadImageURLs, [])

        sut.simulateFeedImageNearVisible(at: 0)
        XCTAssertEqual(loader.loadImageURLs, [url0])

        sut.simulateFeedImageNearVisible(at: 1)
        XCTAssertEqual(loader.loadImageURLs, [url0, url1])
    }

    func test_feedImageView_cancelsLoadingImagesWhenFeedIsNotNearVisibleAnymore() {
        let url0 = URL(string: "https://image0.com")!
        let url1 = URL(string: "https://image1.com")!
        let image0 = makeFeedImage(url: url0)
        let image1 = makeFeedImage(url: url1)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.loadImageURLs, [])

        sut.simulateFeedImageNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelLoadingURLs, [url0])

        sut.simulateFeedImageNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelLoadingURLs, [url0, url1])
    }

    func test_feedImageView_loadsImageURLJustBeforeDisplaying() {
        let url0 = URL(string: "https://image0.com")!
        let url1 = URL(string: "https://image1.com")!
        let image0 = makeFeedImage(url: url0)
        let image1 = makeFeedImage(url: url1)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.loadImageURLs, [])

        sut.simulateFeedImageJustBeforeDisplaying(at: 0)
        XCTAssertEqual(loader.loadImageURLs, [url0])

        sut.simulateFeedImageJustBeforeDisplaying(at: 1)
        XCTAssertEqual(loader.loadImageURLs, [url0, url1])
    }

    func test_feedImageView_doesNotDisplayImageWhenViewIsNotVisibleAnymore() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeLoading(with: [makeFeedImage()], at: 0)

        let view = sut.simulateFeedImageNotVisible(at: 0)
        loader.completeLoadingImage(with: anyImageData(), at: 0)

        XCTAssertNil(view?.renderedImage)
    }

    func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeLoading(at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadImageDataCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoading(with: [makeFeedImage()], at: 0)
        sut.simulateFeedImageVisible(at: 0)
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeLoadingImage(with: self.anyImageData(), at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_errorMessage_isVisibleOnFeedLoadErrorUntilTapped() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertNil(sut.errorMessage)

        loader.completeLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, localized("FEED_VIEW_CONNECTION_ERROR"))

        sut.simulateTapOnErrorMessage()
        XCTAssertNil(sut.errorMessage)
    }

    func test_errorMessage_isVisibleOnFeedLoadErrorUntilReload() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertNil(sut.errorMessage)

        loader.completeLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, localized("FEED_VIEW_CONNECTION_ERROR"))

        sut.simulateUserInitiatedFeedLoad()
        XCTAssertNil(sut.errorMessage)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: FeedLoaderSpy) {
        let loader = FeedLoaderSpy()
        let sut = FeedUIComposer.feedComposedWith(feedLoader: loader, imageLoader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }

    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }

    private func makeFeedImage(id: UUID = UUID(), description: String? = nil, location: String? = nil, url: URL = URL(string: "https://a-url.com")!) -> FeedImage {
        return FeedImage(id: id, description: description, location: location, url: url)
    }

    private func anyImageData() -> Data {
        return UIImage.make(from: .red).pngData()!
    }

    private func assertThat(_ sut: FeedViewController, hasDisplayed feed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        sut.tableView.layoutIfNeeded()
        RunLoop.main.run(until: Date())

        guard sut.numberOfVisibleFeedViews == feed.count else {
            XCTFail("Expected to display \(feed.count) cells, displayed \(sut.numberOfVisibleFeedViews) instead", file: file, line: line)
            return
        }
        assertThat(sut, hasRenderedCorrectly: feed, file: file, line: line)

        RunLoop.current.run(until: Date())
    }

    private func assertThat(_ sut: FeedViewController, hasRenderedCorrectly feed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        feed.enumerated().forEach { index, image in
            let view = sut.feedImageView(at: index)
            XCTAssertEqual(view?.descriptionText, image.description, file: file, line: line)
            XCTAssertEqual(view?.locationText, image.location, file: file, line: line)
            XCTAssertTrue(view?.isShowingLocation == (image.location != nil), file: file, line: line)
        }
    }

    private class FeedLoaderSpy: FeedLoader, FeedImageDataLoader {

        // MARK: - FeedLoader

        var loadCallCount: Int { loadCompletions.count }
        private var loadCompletions: [(FeedLoader.Result) -> Void] = []

        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadCompletions.append(completion)
        }

        func completeLoading(with feed: [FeedImage] = [], at index: Int) {
            loadCompletions[index](.success(feed))
        }

        func completeLoadingWithError(at index: Int) {
            let error = NSError(domain: "domain", code: 1)
            loadCompletions[index](.failure(error))
        }

        // MARK: - FeedImageLoader

        var loadImageURLs: [URL] = []
        private var loadImageCompletions: [(FeedImageDataLoader.Result) -> Void] = []
        @discardableResult
        func loadImage(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageLoaderDataTask {
            let task = TaskSpy { [weak self] in self?.cancelLoadingURLs.append(url) }
            loadImageURLs.append(url)
            loadImageCompletions.append(completion)
            return task
        }

        private struct TaskSpy: FeedImageLoaderDataTask {
            var cancelCallback: () -> Void
            func cancel() {
                cancelCallback()
            }
        }

        var cancelLoadingURLs: [URL] = []

        func completeLoadingImage(with data: Data, at index: Int) {
            loadImageCompletions[index](.success(data))
        }

        func completeLoadingImageWithError(at index: Int) {
            let error = NSError(domain: "error", code: 1)
            loadImageCompletions[index](.failure(error))
        }
    }
}
