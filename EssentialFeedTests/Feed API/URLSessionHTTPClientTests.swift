import EssentialFeed
import XCTest

class URLSessionHTTPClient {
    private let session: URLSession

    private struct UnexpectedResponseError: Error {}

    init(session: URLSession = .shared) {
        self.session = session
    }

    func get(from url: URL, completion: @escaping (HTTPClientResponse) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error {
                completion(.failure(error))
            } else {
                completion(.failure(UnexpectedResponseError()))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {

    override func setUp() {
        super.setUp()
        URLProtocolSpy.register()
    }

    override class func tearDown() {
        super.tearDown()
        URLProtocolSpy.unregister()
    }

    func test_getFromUrl_failsOnError() {
        let expectedError = anyNSError()
        URLProtocolSpy.stub(data: nil, response: nil, error: expectedError)

        let expectation = XCTestExpectation(description: "Wait for response")

        makeSUT().get(from: anyURL()) { response in
            switch response {
            case .failure(let error as NSError):
                XCTAssertEqual(error.domain, expectedError.domain)
                XCTAssertEqual(error.code, expectedError.code)
            default:
                XCTFail("Expected failure, but got \(response)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func test_getFromUrl_failsOnInvalidCase() {
        URLProtocolSpy.stub(data: nil, response: nil, error: nil)

        let expectation = XCTestExpectation(description: "Wait for response")

        makeSUT().get(from: anyURL()) { response in
            switch response {
            case .failure:
                break
            default:
                XCTFail("Expected failure, but got \(response)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func test_getFromUrl_performsGETRequestWithCorrectUrl() {
        let url = anyURL()
        let expectation = XCTestExpectation(description: "Wait for response")

        URLProtocolSpy.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            expectation.fulfill()
        }

        makeSUT().get(from: url, completion: { _ in })

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Helpers

    private func makeSUT(line: UInt = #line, file: StaticString = #filePath) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackMemoryLeak(sut, line: line, file: file)
        return sut
    }

    private class URLProtocolSpy: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?

        private struct Stub {
            let data: Data?
            let response: HTTPURLResponse?
            let error: Error?
        }

        static func register() {
            URLProtocol.registerClass(URLProtocolSpy.self)
        }

        static func unregister() {
            URLProtocol.unregisterClass(URLProtocolSpy.self)
            stub = nil
            requestObserver = nil
        }

        static func observeRequests(_ observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }

        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
            if let error = URLProtocolSpy.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {}

        static func stub(data: Data?, response: HTTPURLResponse?, error: Error?) {
            URLProtocolSpy.stub = Stub(data: data, response: response, error: error)
        }
    }
}
