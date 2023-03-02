import EssentialFeed
import XCTest

class URLSessionHTTPClient {
    private let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromUrl_shouldResumeDataTask() {
        let task = DataTaskSpy()
        let (sut, session) = makeSUT()
        session.stub(url: URL(string: "https://a-url.com")!, with: task)

        sut.get(from: URL(string: "https://a-url.com")!)

        XCTAssertEqual(task.resumeInvocationsCount, 1)
    }

    private func makeSUT() -> (sut: URLSessionHTTPClient, session: URLSessionSpy) {
        let session = URLSessionSpy()
        return (URLSessionHTTPClient(session: session), session)
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
