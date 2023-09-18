import XCTest
import EssentialFeed

class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    private class Task: FeedImageLoaderDataTask {
        func cancel() {

        }
    }

    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {

    }

    func loadImage(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageLoaderDataTask {
        return Task()
    }
}

class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {

    func test_init_doesNotLoadImageData() {
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        _ = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)

        XCTAssertTrue(primaryLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the primary loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
    }

    private func expect(_ sut: FeedLoader, toCompleteWith expectedResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion" )
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
                
            case (.failure, .failure):
                break
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill ()
        }

        wait(for: [exp], timeout: 1.0)
    }

    // MARK: - Helpers

    private class LoaderSpy: FeedImageDataLoader {
        private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()

        var loadedURLs: [URL] {
            return messages.map { $0.url }
        }

        private struct Task: FeedImageLoaderDataTask {
            func cancel() {}
        }

        func loadImage(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageLoaderDataTask {
            messages.append((url, completion))
            return Task()
        }
    }
}
