import EssentialFeed
import XCTest

class URLSessionHTTPClient {
    private let session: URLSession

    private struct UnexpectedResponseError: Error {}

    init(session: URLSession = .shared) {
        self.session = session
    }

    func get(from url: URL, completion: @escaping (HTTPClientResponse) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(response, data))
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

    func test_getFromUrl_failsOnError() {
        let expectedError = anyNSError()
        let receivedError = resultError(data: nil, response: nil, error: expectedError) as? NSError

        XCTAssertEqual(receivedError?.domain, expectedError.domain)
        XCTAssertEqual(receivedError?.code, expectedError.code)
    }

    func test_getFromUrl_failsOnAllInvalidCases() {
        XCTAssertNotNil(resultError(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultError(data: nil, response: anyURLResponse(), error: nil))
        XCTAssertNotNil(resultError(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultError(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultError(data: nil, response: anyURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultError(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultError(data: anyData(), response: anyURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultError(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultError(data: anyData(), response: anyURLResponse(), error: nil))
    }

    func test_getFromUrl_succeedsWithCorrectResponseData() {
        let anyHTTPURLResponse = anyHTTPURLResponse()
        let anyData = anyData()

        let returnedResult = resultSuccess(data: anyData, response: anyHTTPURLResponse, error: nil)

        XCTAssertEqual(returnedResult?.response.url, anyHTTPURLResponse.url)
        XCTAssertEqual(returnedResult?.response.statusCode, anyHTTPURLResponse.statusCode)
        XCTAssertEqual(returnedResult?.data, anyData)
    }

    func test_getFromUrl_completesWithResponseAndEmptyData() {
        let anyHTTPURLResponse = anyHTTPURLResponse()

        let returnedResult = resultSuccess(data: nil, response: anyHTTPURLResponse, error: nil)

        XCTAssertEqual(returnedResult?.response.url, anyHTTPURLResponse.url)
        XCTAssertEqual(returnedResult?.response.statusCode, anyHTTPURLResponse.statusCode)
        XCTAssertEqual(returnedResult?.data, Data())
    }

    // MARK: - Helpers

    private func makeSUT(line: UInt = #line, file: StaticString = #filePath) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackMemoryLeak(sut, line: line, file: file)
        return sut
    }

    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }

    private func anyURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 1, textEncodingName: nil)
    }

    private func anyData() -> Data {
        return Data("any".utf8)
    }

    private func resultError(data: Data?, response: URLResponse?, error: Error?, line: UInt = #line, file: StaticString = #filePath) -> Error? {
        var invokedError: Error?

        guard let result = resultFor(data: data, response: response, error: error) else {
            XCTFail("Expected failure, but got nil", file: file, line: line)
            return nil
        }

        switch result {
        case .failure(let error):
            invokedError = error
        default:
            XCTFail("Expected failure, but got \(result)", file: file, line: line)
        }

        return invokedError
    }

    
    private func resultSuccess(data: Data?, response: URLResponse?, error: Error?, line: UInt = #line, file: StaticString = #filePath) -> (data: Data, response: HTTPURLResponse)? {
        var invokedResult: (data: Data, response: HTTPURLResponse)?

        guard let result = resultFor(data: data, response: response, error: error) else {
            XCTFail("Expected success, but got nil", file: file, line: line)
            return nil
        }

        switch result {
        case let .success(response, data):
            invokedResult = (data, response)
        default:
            XCTFail("Expected success, but got \(result)", file: file, line: line)
        }

        return invokedResult
    }

    private func resultFor(data: Data?, response: URLResponse?, error: Error?, line: UInt = #line, file: StaticString = #filePath) -> HTTPClientResponse? {
        URLProtocolSpy.stub(data: data, response: response, error: error)
        let expectation = XCTestExpectation(description: "Wait for response")
        var invokedResponse: HTTPClientResponse?

        let sut = makeSUT(line: line, file: file)

        sut.get(from: anyURL()) { response in
            invokedResponse = response
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
        return invokedResponse
    }

    private class URLProtocolSpy: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
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
            if let data = URLProtocolSpy.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = URLProtocolSpy.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {}

        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            URLProtocolSpy.stub = Stub(data: data, response: response, error: error)
        }
    }
}
