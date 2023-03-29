import XCTest
import EssentialFeed

class RemoteFeedImageLoader {
    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    typealias Result = Swift.Result<Data, Swift.Error>

    public enum Error: Swift.Error {
        case connection
        case emptyData
        case invalidData
    }

    private class TaskWrapper: FeedImageLoaderDataTask {
        var task: HTTPClientTask?

        func cancel() {
            task?.cancel()
            task = nil
        }
    }

    func loadImage(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageLoaderDataTask {
        let wrapper = TaskWrapper()
        let task = client.get(from: url, completion: { result in
            guard wrapper.task != nil else { return }
            switch result {
            case .success((let data, let response)):
                if data.isEmpty {
                    completion(.failure(Error.emptyData))
                } else if response.statusCode != 200 {
                    completion(.failure(Error.invalidData))
                } else {
                    completion(.success(data))
                }
            case .failure:
                completion(.failure(Error.connection))
            }
        })
        wrapper.task = task
        return wrapper
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

        _ = sut.loadImage(from: url, completion: { _ in })

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadImage_deliversErrorWhenRequestFails() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .failure(RemoteFeedImageLoader.Error.connection), when: {
            let error = NSError(domain: "", code: 1)
            client.complete(with: error)
        })
    }

    func test_loadImage_deliversErrorWhenRequestSucceedsWithEmptyData() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .failure(RemoteFeedImageLoader.Error.emptyData), when: {
            client.complete(withStatusCode: 200, data: makeEmptyData())
        })
    }

    func test_loadImage_deliversErrorWhenRequestSucceedsWithInvalidStatusCode() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .failure(RemoteFeedImageLoader.Error.invalidData), when: {
            client.complete(withStatusCode: 400, data: makeImageData())
        })
    }

    func test_loadImage_deliversImageDataWhenRequestSucceeds() {
        let (sut, client) = makeSUT()
        let imageData = makeImageData()

        expect(sut, toCompleteWith: .success(imageData), when: {
            client.complete(withStatusCode: 200, data: makeImageData())
        })
    }

    func test_cancelTask_doesNotDeliverResult() {
        let (sut, client) = makeSUT()

        var result: RemoteFeedImageLoader.Result?
        let task = sut.loadImage(from: anyURL(), completion: { result = $0 })
        task.cancel()
        client.complete(withStatusCode: 200, data: makeImageData())

        XCTAssertNil(result)
    }

    func test_cancelImageDataTask_cancelsClientDataTask() {
        let (sut, client) = makeSUT()

        let task = sut.loadImage(from: anyURL(), completion: { _ in })
        task.cancel()

        XCTAssertEqual(client.cancelTaskCallCount, 1)
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
        toCompleteWith expectedResult: RemoteFeedImageLoader.Result,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for load completion")
        _ = sut.loadImage(from: anyURL()) { result in
            switch (expectedResult, result) {
            case let (.success(expectedData), .success(data)):
                XCTAssertEqual(expectedData, data, file: file, line: line)
            case let (.failure(expectedError as RemoteFeedImageLoader.Error), .failure(error as RemoteFeedImageLoader.Error)):
                XCTAssertEqual(expectedError, error)
            default:
                XCTFail("Expected \(expectedResult), got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
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

    private class HTTPClientTaskSpy: HTTPClientTask {
        var cancelTaskCallCount: Int = 0
        func cancel() {
            cancelTaskCallCount += 1
        }
    }

    private class HTTPClientSpy: HTTPClient {
        var loadImageCallCount: Int { requestedURLs.count }
        var cancelTaskCallCount: Int { ongoingTask.cancelTaskCallCount }
        var requestedURLs: [URL] = []

        private var getCompletions: [(HTTPClient.Result) -> Void] = []
        private var ongoingTask = HTTPClientTaskSpy()
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            requestedURLs.append(url)
            getCompletions.append(completion)
            ongoingTask = HTTPClientTaskSpy()
            return ongoingTask
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
