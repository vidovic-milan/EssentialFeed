import EssentialFeed
import XCTest

class URLSessionHTTPClient {
    private let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func get(from url: URL, completion: @escaping (Error) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error {
                completion(error)
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromUrl_shouldResumeDataTask() {
        let task = DataTaskSpy()
        let (sut, session) = makeSUT()
        session.stub(url: URL(string: "https://a-url.com")!, with: task)

        sut.get(from: URL(string: "https://a-url.com")!, completion: { _ in })

        XCTAssertEqual(task.resumeInvocationsCount, 1)
    }

    func test_getFromUrl_failsOnError() {
        let (sut, session) = makeSUT()
        let url = URL(string: "https://a-url.com")!
        var invokedError: Error?

        sut.get(from: url, completion: { invokedError = $0 })
        session.complete(with: NSError(domain: "", code: 1))

        XCTAssertEqual(invokedError as? NSError, NSError(domain: "", code: 1))
    }

    private func makeSUT() -> (sut: URLSessionHTTPClient, session: URLSessionSpy) {
        let session = URLSessionSpy()
        return (URLSessionHTTPClient(session: session), session)
    }

    private class URLSessionSpy: URLSession {
        private var stubTaskForUrl = [URL: DataTaskSpy]()
        private var completionHandlers: [(Data?, URLResponse?, Error?) -> Void] = []
        override init() {}

        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            completionHandlers.append(completionHandler)
            return stubTaskForUrl[url] ?? FakeDataTask()
        }

        func complete(with error: Error, at index: Int = 0) {
            completionHandlers[0](nil, nil, error)
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
