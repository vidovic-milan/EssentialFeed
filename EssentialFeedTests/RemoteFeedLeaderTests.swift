import Foundation
import XCTest

class RemoteFeedLoader {
    let client: HTTPClient
    let url: URL

    init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }

    func load() {
        client.get(from: url)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?

    func get(from url: URL) {
        requestedURL = url
    }
}

class RemoteFeedLoaderTests: XCTestCase {
    func test_init_shouldNotGetFromURL() {
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(client: client, url: URL(string: "https://a-url.com")!)

        XCTAssertNil(client.requestedURL)
    }

    func test_load_shouldRequestFromURL() {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: URL(string: "https://a-test-url.com")!)

        sut.load()

        XCTAssertEqual(client.requestedURL, URL(string: "https://a-test-url.com")!)
    }
}
