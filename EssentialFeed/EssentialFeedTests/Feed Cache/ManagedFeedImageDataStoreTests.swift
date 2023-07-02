import XCTest
import EssentialFeed

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

    func test_retrieveImageData_deliversStoredDataWhenDataForUrlIsAvailable() {
        let sut = makeSUT()
        let url = URL(string: "https://a-url.com")!
        let storedData = anyData()

        insert(storedData, for: url, into: sut)

        expect(sut, toCompleteRetrievalWith: found(storedData), for: url)
    }

    func test_retrieveImageData_deliversLastStoredDataWhenDataForUrlIsAvailable() {
        let sut = makeSUT()
        let url = URL(string: "https://a-url.com")!
        let initialData = anyData()
        let lastData = anotherData()

        insert(initialData, for: url, into: sut)
        insert(lastData, for: url, into: sut)

        expect(sut, toCompleteRetrievalWith: found(lastData), for: url)
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

    private func found(_ data: Data) -> FeedImageDataStore.RetrievalResult {
        return .success(data)
    }

    private func anyData() -> Data {
        "any".data(using: .utf8)!
    }

    private func anotherData() -> Data {
        "another".data(using: .utf8)!
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
