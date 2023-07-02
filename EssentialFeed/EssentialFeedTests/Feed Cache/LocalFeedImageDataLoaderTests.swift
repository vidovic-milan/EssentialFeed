import XCTest
import EssentialFeed

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

    func test_save_requestsInsertionFromDataStore() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        let data = anyData()

        sut.save(data: data, for: url) { _ in }

        XCTAssertEqual(store.receivedMessages, [.insert(data: data, for: url)])
    }

    func test_loadImageFromURL_failsOnStoreError() {
        let (sut, store) = makeSUT()
        
        expectLoad(sut, toCompleteWith: .failure(LocalFeedImageDataLoader.LoadError.failed), when: {
            store.completeRetrieval(with: anyNSError())
        })
    }

    func test_save_failsOnStoreError() {
        let (sut, store) = makeSUT()
        
        expectSave(sut, toCompleteWith: .failure(LocalFeedImageDataLoader.SaveError.failed), when: {
            store.completeInsertion(with: anyNSError())
        })
    }

    func test_loadImageFromURL_deliversNotFoundErrorWhenDataForUrlIsMissing() {
        let (sut, store) = makeSUT()

        expectLoad(sut, toCompleteWith: .failure(LocalFeedImageDataLoader.LoadError.notFound), when: {
            store.completeRetrieval(with: nil)
        })
    }

    func test_loadImageFromURL_deliversStoredDataWhenThereIsDataInStore() {
        let (sut, store) = makeSUT()

        let storedData = anyData()
        expectLoad(sut, toCompleteWith: .success(storedData), when: {
            store.completeRetrieval(with: storedData)
        })
    }

    func test_save_succeedsOnSuccessfulStoreInsertion() {
        let (sut, store) = makeSUT()

        expectSave(sut, toCompleteWith: .success(()), when: {
            store.completeInsertionSuccessfully()
        })
    }

    func test_loadImageFromURL_doesNotDeliverDataWhenTaskIsCancelled() {
        let (sut, store) = makeSUT()

        var receivedResults: [FeedImageDataLoader.Result] = []
        let task = sut.loadImage(from: anyURL(), completion: { receivedResults.append($0) })

        task.cancel()

        store.completeRetrieval(with: anyNSError())
        store.completeRetrieval(with: nil)
        store.completeRetrieval(with: anyData())

        XCTAssertTrue(receivedResults.isEmpty)
    }

    func test_loadImageFromURL_doesNotDeliverAnyResultAfterInstanceHasBeenDeallocated() {
        let store = FeedImageStoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)

        var receivedResults: [LocalFeedImageDataLoader.Result] = []
        _ = sut?.loadImage(from: anyURL(), completion: { receivedResults.append($0) })

        sut = nil
        store.completeRetrieval(with: anyNSError())

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

    private func expectLoad(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: LocalFeedImageDataLoader.LoadResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")

        _ = sut.loadImage(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)

            case (.failure(let receivedError as LocalFeedImageDataLoader.LoadError),
                  .failure(let expectedError as LocalFeedImageDataLoader.LoadError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)
    }

    private func expectSave(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: LocalFeedImageDataLoader.SaveResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")

        sut.save(data: anyData(), for: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success, .success):
                break

            case (.failure(let receivedError as LocalFeedImageDataLoader.SaveError),
                  .failure(let expectedError as LocalFeedImageDataLoader.SaveError)):
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
            case insert(data: Data, for: URL)
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

        private var insertCompletions: [(FeedImageDataStore.InsertionResult) -> Void] = []
        func insert(data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
            receivedMessages.append(.insert(data: data, for: url))
            insertCompletions.append(completion)
        }

        func completeInsertion(with error: Error, at index: Int = 0) {
            insertCompletions[index](.failure(error))
        }

        func completeInsertionSuccessfully(at index: Int = 0) {
            insertCompletions[index](.success(()))
        }
    }
}
