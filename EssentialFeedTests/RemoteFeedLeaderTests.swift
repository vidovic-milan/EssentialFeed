import EssentialFeed
import XCTest

class RemoteFeedLoaderTests: XCTestCase {
    func test_init_shouldNotGetFromURL() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs().isEmpty)
    }

    func test_load_shouldRequestFromURL() {
        let url = URL(string: "https://a-test-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load(completion: {_ in})

        XCTAssertEqual(client.requestedURLs(), [url])
    }

    func test_loadTwice_shouldRequestFromURLTwice() {
        let url = URL(string: "https://a-test-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load(completion: {_ in})
        sut.load(completion: {_ in})

        XCTAssertEqual(client.requestedURLs(), [url, url])
    }

    func test_load_shouldReturnErrorOnClientError() {
        let (sut, client) = makeSUT()

        var invokedErrors: [RemoteFeedLoader.Error] = []
        sut.load(completion: { invokedErrors.append($0) })
        client.complete(with: NSError(domain: "Test", code: 0))

        XCTAssertEqual(invokedErrors, [.connectivity])
    }

    func test_load_shouldReturnErrorOnInvalidResponseCode() {
        [199, 201, 300, 400, 500].forEach { code in
            let (sut, client) = makeSUT()

            var invokedErrors: [RemoteFeedLoader.Error] = []
            sut.load(completion: { invokedErrors.append($0) })
            client.complete(with: code)

            XCTAssertEqual(invokedErrors, [.invalidData])
        }
    }

    // MARK: - Helpers

    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        return (RemoteFeedLoader(client: client, url: url), client)
    }

    private class HTTPClientSpy: HTTPClient {
        var getFromUrlInvocations: [(url: URL, completion: (HTTPClientResponse)-> Void)] = []
        func get(from url: URL, completion: @escaping (HTTPClientResponse) -> Void) {
            getFromUrlInvocations.append((url, completion))
        }

        // MARK: - Helpers

        func complete(with error: Error, at index: Int = 0) {
            return getFromUrlInvocations[index].completion(.failure(error))
        }

        func complete(with statusCode: Int, at index: Int = 0) {
            let response = HTTPURLResponse(url: URL(string: "https://a-url.com")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            return getFromUrlInvocations[index].completion(.success(response))
        }

        func requestedURLs() -> [URL] {
            getFromUrlInvocations.map { $0.url }
        }
    }
}
