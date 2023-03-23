import XCTest
import EssentialFeed

struct FeedImageViewModel<Image> {
    let location: String?
    let description: String?
    let isLocationHidden: Bool
    let loadedImage: Image?
    let shouldRetry: Bool
    let isLoading: Bool
}

protocol FeedImageView {
    associatedtype Image

    func display(model: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<Image, View: FeedImageView> where Image == View.Image {

    private let feedImageView: View

    init(feedImageView: View) {
        self.feedImageView = feedImageView
    }
}

final class FeedImagePresenterTests: XCTestCase {
    func test_init_doesNotMessageViewUponCreation() {
        let view = FeedImageViewSpy()
        _ = FeedImagePresenter(feedImageView: view)

        XCTAssertEqual(view.messages, [])
    }

    private class ImageStub: Equatable {
        static func == (lhs: FeedImagePresenterTests.ImageStub, rhs: FeedImagePresenterTests.ImageStub) -> Bool {
            lhs === rhs
        }
    }

    private class FeedImageViewSpy: FeedImageView {
        var messages: [FeedImageViewModel<ImageStub>] = []
        func display(model: FeedImageViewModel<ImageStub>) {
            messages.append(model)
        }
    }
}

extension FeedImageViewModel: Equatable where Image: Equatable {}
