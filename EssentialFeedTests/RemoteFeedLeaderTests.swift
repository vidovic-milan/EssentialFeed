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

class RemoteFeedLoaderTests: XCTestCase {
    func test_init_shouldNotGetFromURL() {
        let (_, client) = makeSUT()

        XCTAssertNil(client.requestedURL)
    }

    func test_load_shouldRequestFromURL() {
        let (sut, client) = makeSUT(url: URL(string: "https://a-test-url.com")!)

        sut.load()

        XCTAssertEqual(client.requestedURL, URL(string: "https://a-test-url.com")!)
    }

    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        return (RemoteFeedLoader(client: client, url: url), client)
    }

    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?

        func get(from url: URL) {
            requestedURL = url
        }
    }
}
