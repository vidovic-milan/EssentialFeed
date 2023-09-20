import EssentialFeed
import Foundation

public final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    private let cache: FeedImageDataCache

    public init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }

    public func loadImage(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageLoaderDataTask {
        return decoratee.loadImage(from: url) { [weak self] result in
            completion(result.map { data in
                self?.cache.save(data: data, for: url) { _ in }
                return data
            })
        }
    }
}
