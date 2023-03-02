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

    func test_getFromUrl_shouldResumeDataTask() {
        let task = DataTaskSpy()
        let (sut, client) = makeSUT()
        client.stub(url: URL(string: "https://a-url.com")!, with: task)

        sut.get(from: URL(string: "https://a-url.com")!)

        XCTAssertEqual(task.resumeInvocationsCount, 1)
    }

    private func makeSUT() -> (sut: URLSessionHTTPClient, client: URLSessionSpy) {
        let client = URLSessionSpy()
        return (URLSessionHTTPClient(client: client), client)
    }

    private class URLSessionSpy: URLSession {
        private var stubTaskForUrl = [URL: DataTaskSpy]()
        override init() {}

        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            return stubTaskForUrl[url] ?? FakeDataTask()
        }

        func stub(url: URL, with task: DataTaskSpy) {
            stubTaskForUrl[url] = task
        }
    }

    private class FakeDataTask: URLSessionDataTask {
        override init() {}
        override func resume() {}
    }

    private class DataTaskSpy: URLSessionDataTask {
        override init() {}

        var resumeInvocationsCount = 0
        override func resume() {
            resumeInvocationsCount += 1
        }
    }
}
