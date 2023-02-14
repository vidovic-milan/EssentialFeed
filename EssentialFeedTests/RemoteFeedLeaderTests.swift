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

        sut.load()

        XCTAssertEqual(client.requestedURLs(), [url])
    }

    func test_loadTwice_shouldRequestFromURLTwice() {
        let url = URL(string: "https://a-test-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load()
        sut.load()

        XCTAssertEqual(client.requestedURLs(), [url, url])
    }

    func test_load_shouldReturnErrorOnClientError() {
        var invokedError: RemoteFeedLoader.Error?
        let (sut, client) = makeSUT()

        sut.load(completion: { invokedError = $0 })
        client.completion(with: NSError(domain: "Test", code: 0))

        XCTAssertEqual(invokedError, .connectivity)
    }

    // MARK: - Helpers

    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        return (RemoteFeedLoader(client: client, url: url), client)
    }

    private class HTTPClientSpy: HTTPClient {
        var getFromUrlInvocations: [(url: URL, completion: (Error)-> Void)] = []
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            getFromUrlInvocations.append((url, completion))
        }

        // MARK: - Helpers

        func completion(with error: Error, at index: Int = 0) {
            return getFromUrlInvocations[index].completion(error)
        }

        func requestedURLs() -> [URL] {
            getFromUrlInvocations.map { $0.url }
        }
    }
}
