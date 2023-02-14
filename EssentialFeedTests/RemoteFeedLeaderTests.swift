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

        expect(sut, toCompleteWithError: .connectivity, when: {
            client.complete(with: NSError(domain: "Test", code: 0))
        })
    }

    func test_load_shouldReturnErrorOnInvalidResponseCode() {
        let (sut, client) = makeSUT()

        [199, 201, 300, 400, 500].enumerated().forEach { value in
            expect(sut, toCompleteWithError: .invalidData, when: {
                client.complete(with: value.element, at: value.offset)
            })
        }
    }

    func test_load_shouldReturnErrorOn200HTTPResponseWithIncorrectJSON() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWithError: .invalidData, when: {
            client.complete(with: 200, data: "invalidJson".data(using: .utf8)!)
        })
    }

    // MARK: - Helpers

    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        return (RemoteFeedLoader(client: client, url: url), client)
    }

    private func expect(
        _ sut: RemoteFeedLoader,
        toCompleteWithError error: RemoteFeedLoader.Error,
        when action: () -> Void,
        line: UInt = #line,
        file: StaticString = #filePath
    ) {
        var invokedErrors: [RemoteFeedLoader.Error] = []
        sut.load(completion: { invokedErrors.append($0) })
        
        action()

        XCTAssertEqual(invokedErrors, [error], file: file, line: line)
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

        func complete(with statusCode: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(url: URL(string: "https://a-url.com")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            return getFromUrlInvocations[index].completion(.success(response, data))
        }

        func requestedURLs() -> [URL] {
            getFromUrlInvocations.map { $0.url }
        }
    }
}
