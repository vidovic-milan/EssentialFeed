import XCTest

class RemoteFeedImageLoader {
    init(client: Any) {}
}

class RemoteFeedImageLoaderTests: XCTestCase {

    func test_init_doesNotLoadFeedImageUponCreation() {
        let client = HTTPImageClientSpy()
        _ = RemoteFeedImageLoader(client: client)

        XCTAssertEqual(client.loadImageCallCount, 0)
    }

    // MARK: - Helpers

    private class HTTPImageClientSpy {
        var loadImageCallCount: Int = 0
    }
}
