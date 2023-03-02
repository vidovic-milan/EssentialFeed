import EssentialFeed
import XCTest

class URLSessionHTTPClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
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

    override func setUp() {
        URLProtocolStub.register()
        super.setUp()
    }

    override class func tearDown() {
        URLProtocolStub.unregister()
        super.tearDown()
    }

    func test_getFromUrl_failsOnError() {
        let sut = makeSUT()
        let url = URL(string: "https://a-url.com")!
        let expectedError = NSError(domain: "", code: 1)
        URLProtocolStub.stub(url: url, data: nil, response: nil, error: expectedError)

        let expectation = XCTestExpectation(description: "get(from: URL)")
        sut.get(from: url, completion: { response in
            switch response {
            case .failure(let error as NSError):
                XCTAssertEqual(error.domain, expectedError.domain)
                XCTAssertEqual(error.code, expectedError.code)
            default:
                XCTFail("Expected failure, but got \(response)")
            }
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1.0)
    }

    private func makeSUT() -> URLSessionHTTPClient {
        return URLSessionHTTPClient()
    }

    private class URLProtocolStub: URLProtocol {
        private static var stubForUrl = [URL: Stub]()

        private struct Stub {
            let data: Data?
            let response: HTTPURLResponse?
            let error: Error?
        }

        static func register() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }

        static func unregister() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubForUrl = [:]
        }

        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            return stubForUrl[url] != nil
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
            guard let url = request.url, let stub = Self.stubForUrl[url] else { return }
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {}

        static func stub(url: URL, data: Data?, response: HTTPURLResponse?, error: Error?) {
            Self.stubForUrl[url] = Stub(data: data, response: response, error: error)
        }
    }
}
