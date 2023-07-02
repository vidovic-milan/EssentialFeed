import Foundation

public class LocalFeedImageDataLoader: FeedImageDataLoader {
    private let store: FeedImageDataStore

    public enum Error: Swift.Error {
        case failed
        case notFound
    }

    class Task: FeedImageLoaderDataTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?

        init(completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }

        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            completion = nil
        }
    }

    public init(store: FeedImageDataStore) {
        self.store = store
    }

    public func loadImage(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageLoaderDataTask {
        let task = Task(completion: completion)
        store.retrieve(dataFor: url) { [weak self] result in
            guard self != nil else { return }
            task.complete(with:
                result
                    .mapError { _ in Error.failed }
                    .flatMap { data in data.map { .success($0) } ?? .failure(Error.notFound) }
            )
        }
        return task
    }
}
