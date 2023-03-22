import XCTest
import EssentialFeed

struct FeedViewModel {
    let feed: [FeedImage]
}

struct FeedLoadingViewModel {
    let isLoading: Bool
}

struct FeedErrorViewModel {
    let message: String?
}

class FeedPresenter {
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView

    init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }

    private static var connectionErrorMessage: String {
        return NSLocalizedString(
            "FEED_VIEW_CONNECTION_ERROR",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Title for the feed view"
        )
    }

    func didStartLoadingFeed() {
        loadingView.display(FeedLoadingViewModel(isLoading: true))
        errorView.display(FeedErrorViewModel(message: .none))
    }

    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }

    func didFinishLoadingFeed(with error: Error) {
        loadingView.display(FeedLoadingViewModel(isLoading: false))
        errorView.display(FeedErrorViewModel(message: Self.connectionErrorMessage))
    }
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenterTests: XCTestCase {
    func test_init_doesNotSendMessagesUponCreation() {
        let (_, view) = makeSUT()

        XCTAssertEqual(view.messages.count, 0)
    }

    func test_didFinishLoadingFeed_displaysFeedAndNoLoading() {
        let (sut, view) = makeSUT()
        let feed = anyFeed()

        sut.didFinishLoadingFeed(with: feed)

        XCTAssertEqual(view.messages, [.feed(feed), .isLoading(false)])
    }

    func test_didStartLoadingFeed_displaysLoadingAndNoError() {
        let (sut, view) = makeSUT()

        sut.didStartLoadingFeed()

        XCTAssertEqual(view.messages, [.isLoading(true), .error(.none)])
    }

    func test_didFinishLoadingFeedWithError_displaysErrorAndNoLoading() {
        let (sut, view) = makeSUT()

        sut.didFinishLoadingFeed(with: NSError(domain: "", code: 1))

        XCTAssertEqual(view.messages, [.isLoading(false), .error(localized("FEED_VIEW_CONNECTION_ERROR"))])
    }

    // MARK: - Helpers

    private func makeSUT(line: UInt = #line, file: StaticString = #file) -> (sut: FeedPresenter, view: FeedViewSpy) {
        let view = FeedViewSpy()
        let sut = FeedPresenter(feedView: view, loadingView: view, errorView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }

    private class FeedViewSpy: FeedView, FeedLoadingView, FeedErrorView {
        enum Message: Equatable {
            case isLoading(Bool)
            case feed([FeedImage])
            case error(String?)
        }
        var messages: [Message] = []

        func display(_ viewModel: FeedViewModel) {
            messages.append(.feed(viewModel.feed))
        }

        func display(_ viewModel: FeedLoadingViewModel) {
            messages.append(.isLoading(viewModel.isLoading))
        }

        func display(_ viewModel: FeedErrorViewModel) {
            messages.append(.error(viewModel.message))
        }
    }

    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: "Feed")
        if value == key {
            XCTFail("Missing localization value for key: \(key)", file: file, line: line)
        }

        return value
    }

    private func anyFeed() -> [FeedImage] {
        return [FeedImage(id: UUID(), description: nil, location: nil, url: URL(string: "https://a-url.com")!)]
    }
}
