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

    class Task: FeedImageLoaderDataTask {
        private var completion: ((Result<Data, Swift.Error>) -> Void)?

        init(completion: @escaping (Result<Data, Swift.Error>) -> Void) {
            self.completion = completion
        }

        func complete(with result: Result<Data, Swift.Error>) {
            completion?(result)
        }
        
        func cancel() {
            completion = nil
        }
    }

    init(store: FeedImageDataStore) {
        self.store = store
    }

    func loadImage(from url: URL, completion: @escaping (Result<Data, Swift.Error>) -> Void) -> FeedImageLoaderDataTask {
        let task = Task(completion: completion)
        store.retrieve(dataFor: url) { result in
            task.complete(with:
                result
                    .mapError { _ in Error.failed }
                    .flatMap { data in data.map { .success($0) } ?? .failure(Error.notFound) }
            )
        }
        return task
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

        _ = sut.loadImage(from: url, completion: { _ in })

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

    func test_loadImageFromURL_deliversStoredDataWhenThereIsDataInStore() {
        let (sut, store) = makeSUT()

        let storedData = anyData()
        expect(sut, toCompleteWith: .success(storedData), when: {
            store.completeRetrieval(with: storedData)
        })
    }

    func test_loadImageFromURL_doesNotDeliverDataWhenTaskIsCancelled() {
        let (sut, store) = makeSUT()

        var receivedResults: [Result<Data, Error>] = []
        let task = sut.loadImage(from: anyURL(), completion: { receivedResults.append($0) })

        task.cancel()

        store.completeRetrieval(with: anyNSError())
        store.completeRetrieval(with: nil)
        store.completeRetrieval(with: anyData())

        XCTAssertTrue(receivedResults.isEmpty)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageStoreSpy) {
        let store = FeedImageStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(store)
        return (sut, store)
    }

    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: Result<Data, Error>, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")

        _ = sut.loadImage(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)

            case (.failure(let receivedError as LocalFeedImageDataLoader.Error),
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

    private func anyData() -> Data {
        "a".data(using: .utf8)!
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
