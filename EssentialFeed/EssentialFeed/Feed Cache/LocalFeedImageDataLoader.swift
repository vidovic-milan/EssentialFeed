import Foundation

public class LocalFeedImageDataLoader {
    private let store: FeedImageDataStore

    public init(store: FeedImageDataStore) {
        self.store = store
    }
}

extension LocalFeedImageDataLoader {
    public typealias SaveResult = Swift.Result<Void, Error>

    public enum SaveError: Swift.Error {
        case failed
    }

    public func save(data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data: data, for: url) { result in
            completion(
                result.mapError { _ in SaveError.failed }
            )
        }
    }
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {
    public typealias LoadResult = FeedImageDataLoader.Result

    public enum LoadError: Swift.Error {
        case failed
        case notFound
    }

    class LoadImageDataTask: FeedImageLoaderDataTask {
        private var completion: ((LoadResult) -> Void)?

        init(completion: @escaping (LoadResult) -> Void) {
            self.completion = completion
        }

        func complete(with result: LoadResult) {
            completion?(result)
        }
        
        func cancel() {
            completion = nil
        }
    }

    public func loadImage(from url: URL, completion: @escaping (LoadResult) -> Void) -> FeedImageLoaderDataTask {
        let task = LoadImageDataTask(completion: completion)
        store.retrieve(dataFor: url) { [weak self] result in
            guard self != nil else { return }
            task.complete(with:
                result
                    .mapError { _ in LoadError.failed }
                    .flatMap { data in data.map { .success($0) } ?? .failure(LoadError.notFound) }
            )
        }
        return task
    }
}
