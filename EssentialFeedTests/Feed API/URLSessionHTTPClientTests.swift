import EssentialFeed
import XCTest

class URLSessionHTTPClient {
    private let client: URLSession

    init(client: URLSession) {
        self.client = client
    }

    func get(from url: URL) {
        client.dataTask(with: url) { _, _, _ in }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    func test_init_shouldNotCreateRequest() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_getFromUrl_createsDataTaskWithUrl() {
        let (sut, client) = makeSUT()

        sut.get(from: URL(string: "https://a-url.com")!)

        XCTAssertEqual(client.requestedURLs, [URL(string: "https://a-url.com")!])
    }

    func test_getFromUrl_shouldResumeDataTask() {
        let task = DataTaskSpy()
        let (sut, client) = makeSUT()
        client.stubTaskForUrl[URL(string: "https://a-url.com")!] = task

        sut.get(from: URL(string: "https://a-url.com")!)

        XCTAssertEqual(task.resumeInvocationsCount, 1)
    }

    private func makeSUT() -> (sut: URLSessionHTTPClient, client: URLSessionSpy) {
        let client = URLSessionSpy()
        return (URLSessionHTTPClient(client: client), client)
    }

    private class URLSessionSpy: URLSession {
        var requestedURLs: [URL] = []
        var stubTaskForUrl = [URL: DataTaskSpy]()
        override init() {}

        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            requestedURLs.append(url)
            return stubTaskForUrl[url] ?? FakeDataTask()
        }
    }

    private class FakeDataTask: URLSessionDataTask {
        override init() {}
    }

    private class DataTaskSpy: URLSessionDataTask {
        override init() {}

        var resumeInvocationsCount = 0
        override func resume() {
            resumeInvocationsCount += 1
        }
    }
}
