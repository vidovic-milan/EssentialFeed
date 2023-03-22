import XCTest
import EssentialFeed

struct FeedViewModel {
    let feed: [FeedImage]
}

struct FeedLoadingViewModel {
    let isLoading: Bool
}

class FeedPresenter {
    private let feedView: FeedView
    private let loadingView: FeedLoadingView

    init(feedView: FeedView, loadingView: FeedLoadingView) {
        self.feedView = feedView
        self.loadingView = loadingView
    }

    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

final class FeedPresenterTests: XCTest {
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

    // MARK: - Helpers

    private func makeSUT(line: UInt = #line, file: StaticString = #file) -> (sut: FeedPresenter, view: FeedViewSpy) {
        let view = FeedViewSpy()
        let sut = FeedPresenter(feedView: view, loadingView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }

    private class FeedViewSpy: FeedView, FeedLoadingView {
        enum Message: Equatable {
            case isLoading(Bool)
            case feed([FeedImage])
        }
        var messages: [Message] = []

        func display(_ viewModel: FeedViewModel) {
            messages.append(.feed(viewModel.feed))
        }

        func display(_ viewModel: FeedLoadingViewModel) {
            messages.append(.isLoading(viewModel.isLoading))
        }
    }

    private func anyFeed() -> [FeedImage] {
        return [FeedImage(id: UUID(), description: nil, location: nil, url: URL(string: "https://a-url.com")!)]
    }
}
