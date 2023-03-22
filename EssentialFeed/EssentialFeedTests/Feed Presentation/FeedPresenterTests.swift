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
        let spy = FeedViewSpy()
        let sut = FeedPresenter(feedView: spy)

        XCTAssertEqual(spy.messages.count, 0)
    }

    func test_didFinishLoadingFeed_displaysFeedAndNoLoading() {
        let spy = FeedViewSpy()
        let sut = FeedPresenter(feedView: spy)

        let feed = anyFeed()
        sut.didFinishLoadingFeed(with: feed)

        XCTAssertEqual(spy.messages, [.feed(feed), .isLoading(false)])
    }

    // MARK: - Helpers

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
