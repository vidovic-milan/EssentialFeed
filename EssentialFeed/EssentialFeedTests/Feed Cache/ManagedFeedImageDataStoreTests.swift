import XCTest
import EssentialFeed

extension ManagedFeedStore: FeedImageDataStore {

    public func insert(data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {

    }

    public func retrieve(dataFor url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        completion(.success(.none))
    }

}

class CoreDataFeedImageDataStoreTests: XCTestCase {

    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        let sut = makeSUT()

        expect(sut, toCompleteRetrievalWith: notFound(), for: anyURL())
    }

    func test_retrieveImageData_deliversNotFoundWhenURLDoesNotMatch() {
        let sut = makeSUT()
        let url = URL(string: "https://a-url.com")!
        let notMatchingUrl = URL(string: "https://different-url.com")!

        insert(anyData(), for: url, into: sut)

        expect(sut, toCompleteRetrievalWith: notFound(), for: notMatchingUrl)
    }

    // - MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> ManagedFeedStore {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! ManagedFeedStore(storeURL: storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func notFound() -> FeedImageDataStore.RetrievalResult {
        return .success(.none)
    }

    private func anyData() -> Data {
        "a".data(using: .utf8)!
    }

    private func localFeedImage(url: URL) -> LocalFeedImage {
        LocalFeedImage(id: UUID(), description: "desc", location: "loc", url: url)
    }

    private func expect(_ sut: ManagedFeedStore, toCompleteRetrievalWith expectedResult: FeedImageDataStore.RetrievalResult, for url: URL,  file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        sut.retrieve(dataFor: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success( receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)

            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    private func insert(_ data: Data, for url: URL, into sut: ManagedFeedStore, file: StaticString = #file, line: UInt = #line) {
            let exp = expectation(description: "Wait for cache insertion")
            let image = localFeedImage(url: url)
            sut.insert([image], timestamp: Date()) { result in
                switch result {
                case let .failure(error):
                    XCTFail("Failed to save \(image) with error \(error)", file: file, line: line)

                case .success:
                    sut.insert(data: data, for: url) { result in
                        if case let Result.failure(error) = result {
                            XCTFail("Failed to insert \(data) with error \(error)", file: file, line: line)
                        }
                    }
                }
                exp.fulfill()
            }
            wait(for: [exp], timeout: 1.0)
        }

}
