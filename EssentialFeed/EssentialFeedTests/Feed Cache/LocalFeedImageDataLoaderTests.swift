import XCTest
import EssentialFeed

protocol FeedImageDataStore {
    func retrieve(dataFor url: URL)
}

class LocalFeedImageDataLoader {
    private let store: FeedImageDataStore

    init(store: FeedImageDataStore) {
        self.store = store
    }

    func loadImage(from url: URL) {
        store.retrieve(dataFor: url)
    }
}

class LocalFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let store = FeedImageStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_loadImageFromURL_requestsStoredDataForURL() {
        let store = FeedImageStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        let url = anyURL()

        sut.loadImage(from: url)

        XCTAssertEqual(store.receivedMessages, [.retrieve(dataFor: url)])
    }

    // MARK: - Helpers

    private class FeedImageStoreSpy: FeedImageDataStore {
        enum Message: Equatable {
            case retrieve(dataFor: URL)
        }
        var receivedMessages: [Message] = []

        func retrieve(dataFor url: URL) {
            receivedMessages.append(.retrieve(dataFor: url))
        }
    }
}
