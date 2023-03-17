import XCTest
import UIKit
import EssentialFeed

class FeedViewController: UIViewController {
    private var loader: FeedLoader?

    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loader?.load { _ in }
    }
}

class FeedViewControllerTests: XCTestCase {
    func test_init_doesNotCallLoad() {
        let loader = FeedLoaderSpy()
        _ = FeedViewController(loader: loader)

        XCTAssertEqual(loader.loadCallCount, 0)
    }

    func test_viewDidLoad_loadsFeed() {
        let loader = FeedLoaderSpy()
        let sut = FeedViewController(loader: loader)

        sut.loadViewIfNeeded()

        XCTAssertEqual(loader.loadCallCount, 1)
    }

    private class FeedLoaderSpy: FeedLoader {
        private(set) var loadCallCount = 0

        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadCallCount += 1
        }
    }
}
