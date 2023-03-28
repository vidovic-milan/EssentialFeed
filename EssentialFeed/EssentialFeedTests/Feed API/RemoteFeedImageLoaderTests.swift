import XCTest
import EssentialFeed

class RemoteFeedImageLoader {
    private let client: HTTPClient
    init(client: HTTPClient) {
        self.client = client
    }

    private enum ImageDataLoaderError: Error {
        case emptyData
    }

    func loadImage(from url: URL, completion: @escaping (Error) -> Void) {
        client.get(from: url, completion: { result in
            switch result {
            case .failure(let error):
                completion(error)
            case .success((let data, _)):
                if data.isEmpty {
                    completion(ImageDataLoaderError.emptyData)
                }
            }
        })
    }
}

class RemoteFeedImageLoaderTests: XCTestCase {

    func test_init_doesNotLoadFeedImageUponCreation() {
        let (_, client) = makeSUT()

        XCTAssertEqual(client.loadImageCallCount, 0)
    }

    func test_loadImage_requestsImageFromURL() {
        let url = anyURL()
        let (sut, client) = makeSUT()

        sut.loadImage(from: url, completion: { _ in })

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadImage_deliversErrorWhenRequestFails() {
        let url = anyURL()
        let (sut, client) = makeSUT()

        var receivedError: Error?
        let exp = expectation(description: "wait for load completion")
        sut.loadImage(from: url) {
            receivedError = $0
            exp.fulfill()
        }

        client.complete(with: NSError(domain: "", code: 1))

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as? NSError, NSError(domain: "", code: 1))
    }

    func test_loadImage_deliversErrorWhenRequestSucceedsWithEmptyData() {
        let url = anyURL()
        let (sut, client) = makeSUT()

        var receivedError: Error?
        let exp = expectation(description: "wait for load completion")
        sut.loadImage(from: url) {
            receivedError = $0
            exp.fulfill()
        }

        client.complete(with: Data(), response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!)

        wait(for: [exp], timeout: 1.0)
        XCTAssertNotNil(receivedError)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageLoader(client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }

    private class HTTPClientSpy: HTTPClient {
        var loadImageCallCount: Int { requestedURLs.count }
        var requestedURLs: [URL] = []

        private var getCompletions: [(HTTPClient.Result) -> Void] = []
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            requestedURLs.append(url)
            getCompletions.append(completion)
        }

        func complete(with error: Error, at index: Int = 0) {
            getCompletions[index](.failure(error))
        }

        func complete(with data: Data, response: HTTPURLResponse, at index: Int = 0) {
            getCompletions[index](.success((data, response)))
        }
    }
}
