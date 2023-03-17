import XCTest
import EssentialFeed
import EssentialFeediOS

class FeedViewControllerTests: XCTestCase {
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
        let image0 = makeImage(description: "a desc", location: "a loc")
        let image1 = makeImage(description: nil, location: "a loc")
        let image2 = makeImage(description: "a desc", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        assertThat(sut, hasDisplayed: [])

        loader.completeLoading(with: [image0], at: 0)
        assertThat(sut, hasDisplayed: [image0])

        sut.simulateUserInitiatedFeedLoad()
        loader.completeLoading(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, hasDisplayed: [image0, image1, image2, image3])
    }

    func test_loadFeedCompletion_doesNotAlterCurrentImages() {
        let image0 = makeImage(description: "a desc", location: "a loc")
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image0], at: 0)
        assertThat(sut, hasDisplayed: [image0])

        sut.simulateUserInitiatedFeedLoad()
        loader.completeLoadingWithError(at: 1)
        assertThat(sut, hasDisplayed: [image0])
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: FeedLoaderSpy) {
        let loader = FeedLoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }

    private func makeImage(id: UUID = UUID(), description: String? = nil, location: String? = nil, url: URL = URL(string: "https://a-url.com")!) -> FeedImage {
        return FeedImage(id: id, description: description, location: location, url: url)
    }

    private func assertThat(_ sut: FeedViewController, hasDisplayed feed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        guard sut.numberOfVisibleFeedViews == feed.count else {
            XCTFail("Expected to display \(feed.count) cells, displayed \(sut.numberOfVisibleFeedViews) instead", file: file, line: line)
            return
        }
        assertThat(sut, hasRenderedCorrectly: feed, file: file, line: line)
    }

    private func assertThat(_ sut: FeedViewController, hasRenderedCorrectly feed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        feed.enumerated().forEach { index, image in
            let view = sut.feedImageView(at: index)
            XCTAssertEqual(view?.descriptionText, image.description, file: file, line: line)
            XCTAssertEqual(view?.locationText, image.location, file: file, line: line)
            XCTAssertTrue(view?.isShowingLocation == (image.location != nil), file: file, line: line)
        }
    }

    private class FeedLoaderSpy: FeedLoader {
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
    }
}

private extension FeedImageCell {
    var descriptionText: String? {
        return descriptionLabel.text
    }

    var locationText: String? {
        return locationLabel.text
    }

    var isShowingLocation: Bool {
        return locationContainer.isHidden == false
    }
}

private extension UITableViewController {
    var numberOfVisibleFeedViews: Int {
        tableView.numberOfRows(inSection: feedSection)
    }

    private var feedSection: Int {
        return 0
    }

    var isLoadingIndicatorVisible: Bool {
        refreshControl?.isRefreshing == true
    }

    func feedImageView(at index: Int) -> FeedImageCell? {
        tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: index, section: feedSection)) as? FeedImageCell
    }

    func simulateUserInitiatedFeedLoad() {
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                (self as NSObject).perform(Selector(action))
            }
        }
    }
}
