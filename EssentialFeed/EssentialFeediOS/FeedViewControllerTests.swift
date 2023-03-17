import XCTest

class FeedViewController {
    init(loader: FeedViewControllerTests.FeedLoaderSpy) {
    }
}

class FeedViewControllerTests: XCTestCase {
    func test_init_doesNotCallLoad() {
        let loader = FeedLoaderSpy()
        _ = FeedViewController(loader: loader)

        XCTAssertEqual(loader.loadCallCount, 0)
    }

    class FeedLoaderSpy {
        private(set) var loadCallCount = 0
    }
}
