import Foundation
import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.requestedURL = URL(string: "https://a-url.com")!
    }
}

class HTTPClient {
    static let shared = HTTPClient()
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    func test_init_shouldNotGetFromURL() {
        let client = HTTPClient.shared
        _ = RemoteFeedLoader()

        XCTAssertNil(client.requestedURL)
    }

    func test_load_shouldRequestFromURL() {
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader()

        sut.load()

        XCTAssertNotNil(client.requestedURL)
    }
}
