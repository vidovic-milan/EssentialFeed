import EssentialFeed
import XCTest

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionDataTask
}

protocol HTTPSessionDataTask {
    func resume()
}

class URLSessionHTTPClient {
    private let session: HTTPSession

    init(session: HTTPSession) {
        self.session = session
    }

    func get(from url: URL, completion: @escaping (HTTPClientResponse) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error {
                completion(.failure(error))
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
        session.stub(url: url, error: NSError(domain: "", code: 1))

        let expectation = XCTestExpectation(description: "get(from: URL)")
        sut.get(from: url, completion: { response in
            switch response {
            case .failure(let error as NSError):
                XCTAssertEqual(error, NSError(domain: "", code: 1))
            default:
                XCTFail("Expected failure, but got \(response)")
            }
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1.0)
    }

    private func makeSUT() -> (sut: URLSessionHTTPClient, session: URLSessionSpy) {
        let session = URLSessionSpy()
        return (URLSessionHTTPClient(session: session), session)
    }

    private class URLSessionSpy: HTTPSession {
        private var stubTaskForUrl = [URL: Stub]()
        private var completionHandlers: [(Data?, URLResponse?, Error?) -> Void] = []

        private struct Stub {
            let task: HTTPSessionDataTask
            let error: Error?
        }

        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionDataTask {
            guard let stub = stubTaskForUrl[url] else {
                fatalError("Stub is not set")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }

        func stub(url: URL, with task: HTTPSessionDataTask = FakeDataTask(), error: Error? = nil) {
            stubTaskForUrl[url] = Stub(task: task, error: error)
        }
    }

    private class FakeDataTask: HTTPSessionDataTask {
        func resume() {}
    }

    private class DataTaskSpy: HTTPSessionDataTask {
        var resumeInvocationsCount = 0
        func resume() {
            resumeInvocationsCount += 1
        }
    }
}
