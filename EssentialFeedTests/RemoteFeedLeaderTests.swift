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

        expect(sut, toCompleteWith: .failure(.connectivity), when: {
            client.complete(with: NSError(domain: "Test", code: 0))
        })
    }

    func test_load_shouldReturnErrorOnInvalidResponseCode() {
        let (sut, client) = makeSUT()

        [199, 201, 300, 400, 500].enumerated().forEach { value in
            expect(sut, toCompleteWith: .failure(.invalidData), when: {
                client.complete(with: value.element, data: makeItemsData(), at: value.offset)
            })
        }
    }

    func test_load_shouldReturnErrorOn200HTTPResponseWithIncorrectJSON() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .failure(.invalidData), when: {
            client.complete(with: 200, data: "invalidJson".data(using: .utf8)!)
        })
    }

    func test_load_shouldReturnEmptyArrayOn200HttpResponseWithEmptyArrayJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([]), when: {
            client.complete(with: 200, data: makeItemsData())
        })
    }

    func test_load_shouldReturnCorrectItemsOn200HttpResponseWithItemsJSON() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(id: UUID(), imageURL: URL(string: "https://a-url.com")!)
        let item2 = makeItem(id: UUID(), description: "description", location: "location", imageURL: URL(string: "https://another-url.com")!)

        let items = [item1.model, item2.model]
        let itemsData = makeItemsData([item1.json, item2.json])
        
        expect(sut, toCompleteWith: .success(items), when: {
            client.complete(with: 200, data: itemsData)
        })
    }

    // MARK: - Helpers

    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        return (RemoteFeedLoader(client: client, url: url), client)
    }

    private func expect(
        _ sut: RemoteFeedLoader,
        toCompleteWith result: RemoteFeedLoader.Result,
        when action: () -> Void,
        line: UInt = #line,
        file: StaticString = #filePath
    ) {
        var invokedResults: [RemoteFeedLoader.Result] = []
        sut.load(completion: { invokedResults.append($0) })
        
        action()

        XCTAssertEqual(invokedResults, [result], file: file, line: line)
    }

    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        let itemJSON = [
            "id": item.id.uuidString,
            "image": item.imageURL.absoluteString,
            "description": item.description,
            "location": item.location
        ].reduce(into: [String: Any]()) { partialResult, item in
            if let value = item.value { partialResult[item.key] = value }
        }
        return (item, itemJSON)
    }

    private func makeItemsData(_ items: [[String: Any]] = []) -> Data {
        let itemsJSON = ["items": items]
        return try! JSONSerialization.data(withJSONObject: itemsJSON)
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

        func complete(with statusCode: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: URL(string: "https://a-url.com")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            return getFromUrlInvocations[index].completion(.success(response, data))
        }

        func requestedURLs() -> [URL] {
            getFromUrlInvocations.map { $0.url }
        }
    }
}
