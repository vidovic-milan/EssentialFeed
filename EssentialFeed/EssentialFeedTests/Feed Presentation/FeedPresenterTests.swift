import XCTest
import EssentialFeed

struct FeedViewModel {
    let feed: [FeedImage]
}

class FeedPresenter {
    private let feedView: FeedView

    init(feedView: FeedView) {
        self.feedView = feedView
    }
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

final class FeedPresenterTests: XCTest {
    func test_init_doesNotSendMessagesUponCreation() {
        let spy = FeedViewSpy()
        let sut = FeedPresenter(feedView: spy)

        XCTAssertEqual(spy.messages.count, 0)
    }

    // MARK: - Helpers

    class FeedViewSpy: FeedView {
        var messages: [Any] = []

        func display(_ viewModel: FeedViewModel) {
            
        }
    }
}
