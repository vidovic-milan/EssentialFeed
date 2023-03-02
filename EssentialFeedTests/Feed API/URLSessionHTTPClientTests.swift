import EssentialFeed
import XCTest

class URLSessionHTTPClient {
    private let client: URLSession

    init(client: URLSession) {
        self.client = client
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    func test_shouldNotCreateRequestOnInit() {
        let client = URLSessionSpy()
        let _ = URLSessionHTTPClient(client: client)

        XCTAssertTrue(client.requestedURLs.isEmpty)
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
