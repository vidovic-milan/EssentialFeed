import XCTest
import EssentialFeed

protocol FeedImageDataStore {
    func retrieve(dataFor url: URL, completion: @escaping (Error) -> Void)
}

class LocalFeedImageDataLoader {
    private let store: FeedImageDataStore

    public enum Error: Swift.Error {
        case failed
    }

    init(store: FeedImageDataStore) {
        self.store = store
    }

    func loadImage(from url: URL, completion: @escaping (Error) -> Void) {
        store.retrieve(dataFor: url) { result in
            completion(Error.failed)
        }
    }
}

class LocalFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_loadImageFromURL_requestsStoredDataForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()

        sut.loadImage(from: url, completion: { _ in })

        XCTAssertEqual(store.receivedMessages, [.retrieve(dataFor: url)])
    }

    func test_loadImageFromURL_failsOnStoreError() {
        let (sut, store) = makeSUT()
        let url = anyURL()

        let retrievalError = anyNSError()
        var receivedError: Error?
        let exp = expectation(description: "wait for image load")
        sut.loadImage(from: url, completion: { error in
            receivedError = error
            exp.fulfill()
        })
        
        store.completeRetrieval(with: retrievalError)
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedError as? LocalFeedImageDataLoader.Error, .failed)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageStoreSpy) {
        let store = FeedImageStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(store)
        return (sut, store)
    }

    private class FeedImageStoreSpy: FeedImageDataStore {
        enum Message: Equatable {
            case retrieve(dataFor: URL)
        }
        var receivedMessages: [Message] = []
        private var retrieveCompletions: [(Error) -> Void] = []

        func retrieve(dataFor url: URL, completion: @escaping (Error) -> Void) {
            receivedMessages.append(.retrieve(dataFor: url))
            retrieveCompletions.append(completion)
        }

        func completeRetrieval(with error: Error, at index: Int = 0) {
            retrieveCompletions[index](error)
        }
    }
}
