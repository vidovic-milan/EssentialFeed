import EssentialFeed
import XCTest

class RemoteFeedLoaderTests: XCTestCase {
    func test_init_shouldNotGetFromURL() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.getFromUrlInvocations.isEmpty)
    }

    func test_load_shouldRequestFromURL() {
        let url = URL(string: "https://a-test-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load()

        XCTAssertEqual(client.getFromUrlInvocations.map { $0.url }, [url])
    }

    func test_loadTwice_shouldRequestFromURLTwice() {
        let url = URL(string: "https://a-test-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load()
        sut.load()

        XCTAssertEqual(client.getFromUrlInvocations.map { $0.url }, [url, url])
    }

    func test_load_shouldReturnErrorOnClientError() {
        var invokedError: RemoteFeedLoader.Error?
        let (sut, client) = makeSUT()

        sut.load(completion: { invokedError = $0 })
        client.getFromUrlInvocations.first?.completion(NSError(domain: "Test", code: 0))

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
    }
}
