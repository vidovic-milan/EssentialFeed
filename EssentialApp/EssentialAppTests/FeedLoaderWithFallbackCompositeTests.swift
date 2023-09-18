import XCTest
import EssentialFeed

class FeedLoaderWithFallbackComposite: FeedLoader {
    private let primary: FeedLoader

    init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
    }

    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load(completion: completion)
    }
}

class FeedLoaderWithFallbackCompositeTests: XCTestCase {

    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        let primaryLoader = LoaderStub(result: .success(primaryFeed))
        let fallbackLoader = LoaderStub(result: .success(fallbackFeed))
        let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)

        let exp = expectation(description: "wait for load")
        sut.load { result in
            switch result {
            case .success(let receivedFeed):
                XCTAssertEqual(receivedFeed, primaryFeed)
            
            case .failure:
                XCTFail("Expected feed loading to succeed")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    // MARK: - Helpers

    private func uniqueFeed() -> [FeedImage] {
        [FeedImage(id: UUID(), description: "a desc", location: "a location", url: URL(string: "https://any-url.com")!)]
    }

    private class LoaderStub: FeedLoader {
        private let result: FeedLoader.Result

        init(result: FeedLoader.Result) {
            self.result = result
        }

        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }
}
