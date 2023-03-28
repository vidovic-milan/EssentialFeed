import XCTest
import EssentialFeed

class RemoteFeedImageLoader {
    private let client: HTTPClient
    init(client: HTTPClient) {
        self.client = client
    }

    public enum Error: Swift.Error {
        case connection
        case emptyData
        case invalidData
    }

    func loadImage(from url: URL, completion: @escaping (Swift.Error) -> Void) {
        client.get(from: url, completion: { result in
            switch result {
            case .success((let data, let response)):
                if data.isEmpty {
                    completion(Error.emptyData)
                } else if response.statusCode != 200 {
                    completion(Error.invalidData)
                }
            case .failure:
                completion(Error.connection)
            }
        })
    }
}

class RemoteFeedImageLoaderTests: XCTestCase {

    func test_init_doesNotLoadFeedImageUponCreation() {
        let (_, client) = makeSUT()

        XCTAssertEqual(client.loadImageCallCount, 0)
    }

    func test_loadImage_requestsImageFromURL() {
        let url = anyURL()
        let (sut, client) = makeSUT()

        sut.loadImage(from: url, completion: { _ in })

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadImage_deliversErrorWhenRequestFails() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWithError: RemoteFeedImageLoader.Error.connection, when: {
            let error = NSError(domain: "", code: 1)
            client.complete(with: error)
        })
    }

    func test_loadImage_deliversErrorWhenRequestSucceedsWithEmptyData() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWithError: RemoteFeedImageLoader.Error.emptyData, when: {
            client.complete(withStatusCode: 200, data: makeEmptyData())
        })
    }

    func test_loadImage_deliversErrorWhenRequestSucceedsWithInvalidStatusCode() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWithError: RemoteFeedImageLoader.Error.invalidData, when: {
            client.complete(withStatusCode: 400, data: makeImageData())
        })
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageLoader(client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }

    private func expect(
        _ sut: RemoteFeedImageLoader,
        toCompleteWithError error: Error,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedError: Error?
        let exp = expectation(description: "wait for load completion")
        sut.loadImage(from: anyURL()) {
            receivedError = $0
            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as? RemoteFeedImageLoader.Error, error as? RemoteFeedImageLoader.Error)
    }

    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }

    private func makeImageData() -> Data {
        return "abc".data(using: .utf8)!
    }

    private func makeEmptyData() -> Data {
        return Data()
    }

    private class HTTPClientSpy: HTTPClient {
        var loadImageCallCount: Int { requestedURLs.count }
        var requestedURLs: [URL] = []

        private var getCompletions: [(HTTPClient.Result) -> Void] = []
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            requestedURLs.append(url)
            getCompletions.append(completion)
        }

        func complete(with error: Error, at index: Int = 0) {
            getCompletions[index](.failure(error))
        }

        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            getCompletions[index](.success((data, response)))
        }
    }
}
