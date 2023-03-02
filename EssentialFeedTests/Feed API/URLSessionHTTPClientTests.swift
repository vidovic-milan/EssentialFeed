import EssentialFeed
import XCTest

class URLSessionHTTPClient {
    private let client: URLSession

    init(client: URLSession) {
        self.client = client
    }

    func get(from url: URL) {
        client.dataTask(with: url) { _, _, _ in }
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    func test_init_shouldNotCreateRequest() {
        let client = URLSessionSpy()
        let _ = URLSessionHTTPClient(client: client)

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_getFromUrl_shouldRequestFromClient() {
        let client = URLSessionSpy()
        let sut = URLSessionHTTPClient(client: client)

        sut.get(from: URL(string: "https://a-url.com")!)

        XCTAssertEqual(client.requestedURLs, [URL(string: "https://a-url.com")!])
    }

    private class URLSessionSpy: URLSession {
        var requestedURLs: [URL] = []
        override init() {}

        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            requestedURLs.append(url)
            return URLSessionDataTask()
        }
    }
}
