import XCTest
import EssentialFeed

protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}

final class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    private let cache: FeedCache

    init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }

    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.cache.save((try? result.get()) ?? []) { _ in }
            completion(result)
        }
    }
}

class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {

    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let sut = makeSUT(loaderResult: .success(feed))

        expect(sut, toCompleteWith: .success(feed))
    }

    func test_load_deliversErrorOnLoaderFailure() {
        let sut = makeSUT(loaderResult: .failure(anyNSError()))

        expect(sut, toCompleteWith: .failure(anyNSError()))
    }

    func test_load_cachesLoadedFeedOnLoaderSuccess() {
        let cache = CacheSpy()
        let feed = uniqueFeed()
        let sut = makeSUT(loaderResult: .success(feed), cache: cache)

        sut.load { _ in }

        XCTAssertEqual(cache.messages, [.save(feed)], "Expected to cache loaded feed on success")
    }

    // MARK: - Helpers
    
    private func makeSUT(loaderResult: FeedLoader.Result, cache: CacheSpy = .init(), file: StaticString = #file, line: UInt = #line) -> FeedLoader {
        let loader = LoaderStub(result: loaderResult)
        let sut = FeedLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }

    private func uniqueFeed() -> [FeedImage] {
        return [FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())]
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

    private class CacheSpy: FeedCache {
        private(set) var messages = [Message]()

        enum Message: Equatable {
            case save([FeedImage])
        }

        func save(_ feed: [FeedImage], completion: @escaping (FeedCache.Result) -> Void) {
            messages.append(.save(feed))
            completion(.success(()))
        }
    }

    private func anyURL() -> URL {
        return URL(string: "http://a-url.com")!
    }

    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
}
