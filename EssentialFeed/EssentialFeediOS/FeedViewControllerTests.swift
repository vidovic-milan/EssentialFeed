import XCTest
import UIKit
import EssentialFeed

class FeedViewController: UITableViewController {
    private var loader: FeedLoader?

    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadFeed), for: .valueChanged)
        loader?.load { _ in }
    }

    @objc private func loadFeed() {
        loader?.load { _ in }
    }
}

class FeedViewControllerTests: XCTestCase {
    func test_init_doesNotCallLoad() {
        let (_, loader) = makeSUT()

        XCTAssertEqual(loader.loadCallCount, 0)
    }

    func test_viewDidLoad_loadsFeed() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertEqual(loader.loadCallCount, 1)
    }

    func test_pullToRefresh_loadsFeed() {
        let (sut, loader) = makeSUT()

        sut.simulatePullToRefresh()
        XCTAssertEqual(loader.loadCallCount, 2)

        sut.simulatePullToRefresh()
        XCTAssertEqual(loader.loadCallCount, 3)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: FeedLoaderSpy) {
        let loader = FeedLoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }

    private class FeedLoaderSpy: FeedLoader {
        private(set) var loadCallCount = 0

        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadCallCount += 1
        }
    }
}

private extension UITableViewController {
    func simulatePullToRefresh() {
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                (self as NSObject).perform(Selector(action))
            }
        }
    }
}
