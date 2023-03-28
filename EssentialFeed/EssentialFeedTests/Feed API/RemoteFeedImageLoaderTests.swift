import XCTest
import EssentialFeed

class RemoteFeedImageLoader {
    private let client: HTTPClient
    init(client: HTTPClient) {
        self.client = client
    }

    func loadImage(from url: URL) {
        client.get(from: url, completion: { _ in })
    }
}

class RemoteFeedImageLoaderTests: XCTestCase {

    func test_init_doesNotLoadFeedImageUponCreation() {
        let client = HTTPClientSpy()
        _ = RemoteFeedImageLoader(client: client)

        XCTAssertEqual(client.loadImageCallCount, 0)
    }

    func test_loadImage_requestsImageFromURL() {
        let url = anyURL()
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageLoader(client: client)

        sut.loadImage(from: url)

        XCTAssertEqual(client.requestedURLs, [url])
    }

    // MARK: - Helpers

    private class HTTPClientSpy: HTTPClient {
        var loadImageCallCount: Int { requestedURLs.count }
        var requestedURLs: [URL] = []

        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            requestedURLs.append(url)
        }
    }
}
