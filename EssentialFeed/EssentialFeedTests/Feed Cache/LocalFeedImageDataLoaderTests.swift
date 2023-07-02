import XCTest
import EssentialFeed

protocol FeedImageDataStore {
    typealias RetrievalResult = Swift.Result<Data?, Error>
    func retrieve(dataFor url: URL, completion: @escaping (RetrievalResult) -> Void)
}

class LocalFeedImageDataLoader {
    private let store: FeedImageDataStore

    public enum Error: Swift.Error {
        case failed
        case notFound
    }

    init(store: FeedImageDataStore) {
        self.store = store
    }

    func loadImage(from url: URL, completion: @escaping (Result<Data?, Error>) -> Void) {
        store.retrieve(dataFor: url) { result in
            switch result {
            case .success:
                completion(.failure(.notFound))
            case .failure:
                completion(.failure(.failed))
            }
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
        
        expect(sut, toCompleteWith: .failure(LocalFeedImageDataLoader.Error.failed), when: {
            store.completeRetrieval(with: anyNSError())
        })
    }

    func test_loadImageFromURL_deliversNotFoundErrorWhenDataForUrlIsMissing() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: .failure(LocalFeedImageDataLoader.Error.notFound), when: {
            store.completeRetrieval(with: nil)
        })
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageStoreSpy) {
        let store = FeedImageStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(store)
        return (sut, store)
    }

    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: Result<Data?, Error>, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")

        sut.loadImage(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)

            case (.failure(let receivedError),
                  .failure(let expectedError as LocalFeedImageDataLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)
    }

    private class FeedImageStoreSpy: FeedImageDataStore {
        enum Message: Equatable {
            case retrieve(dataFor: URL)
        }
        var receivedMessages: [Message] = []
        private var retrieveCompletions: [(FeedImageDataStore.RetrievalResult) -> Void] = []

        func retrieve(dataFor url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
            receivedMessages.append(.retrieve(dataFor: url))
            retrieveCompletions.append(completion)
        }

        func completeRetrieval(with error: Error, at index: Int = 0) {
            retrieveCompletions[index](.failure(error))
        }

        func completeRetrieval(with data: Data?, at index: Int = 0) {
            retrieveCompletions[index](.success(data))
        }
    }
}
