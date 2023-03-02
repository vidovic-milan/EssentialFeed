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
        session.stub(url: url, error: NSError(domain: "", code: 1))

        sut.get(from: url, completion: { invokedError = $0 })

        XCTAssertEqual(invokedError as? NSError, NSError(domain: "", code: 1))
    }

    private func makeSUT() -> (sut: URLSessionHTTPClient, session: URLSessionSpy) {
        let session = URLSessionSpy()
        return (URLSessionHTTPClient(session: session), session)
    }

    private class URLSessionSpy: URLSession {
        private var stubTaskForUrl = [URL: Stub]()
        private var completionHandlers: [(Data?, URLResponse?, Error?) -> Void] = []

        private struct Stub {
            let task: URLSessionDataTask
            let error: Error?
        }
        override init() {}

        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            guard let stub = stubTaskForUrl[url] else {
                fatalError("Stub is not set")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }

        func stub(url: URL, with task: URLSessionDataTask = FakeDataTask(), error: Error? = nil) {
            stubTaskForUrl[url] = Stub(task: task, error: error)
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
