import EssentialFeed
import XCTest

class RemoteFeedLoaderTests: XCTestCase {
    func test_init_shouldNotGetFromURL() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_shouldRequestFromURL() {
        let url = URL(string: "https://a-test-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load()

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadTwice_shouldRequestFromURLTwice() {
        let url = URL(string: "https://a-test-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load()
        sut.load()

        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    // MARK: - Helpers

    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        return (RemoteFeedLoader(client: client, url: url), client)
    }

    private class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] = []

        func get(from url: URL) {
            requestedURLs.append(url)
        }
    }
}
