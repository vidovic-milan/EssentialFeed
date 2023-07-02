import XCTest
import EssentialFeed

protocol FeedImageDataStore {}

class LocalFeedImageDataLoader {
    private let store: FeedImageDataStore

    init(store: FeedImageDataStore) {
        self.store = store
    }
}

class LocalFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let store = FeedImageStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)

        XCTAssertEqual(store.receivedMessages, [])
    }

    // MARK: - Helpers

    private class FeedImageStoreSpy: FeedImageDataStore {
        enum Message: Equatable {}
        var receivedMessages: [Message] = []
    }
}
