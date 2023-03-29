import Foundation

public class RemoteFeedImageLoader: FeedImageDataLoader {
    private let client: HTTPClient

    public init(client: HTTPClient) {
        self.client = client
    }

    public typealias Result = FeedImageDataLoader.Result

    public enum Error: Swift.Error {
        case connection
        case emptyData
        case invalidData
    }

    private class TaskWrapper: FeedImageLoaderDataTask {
        private var completion: ((Result) -> Void)?

        var task: HTTPClientTask?

        init(completion: @escaping (Result) -> Void) {
            self.completion = completion
        }

        func cancel() {
            preventFurtherCompletion()
            task?.cancel()
        }

        func complete(with result: Result) {
            completion?(result)
        }

        private func preventFurtherCompletion() {
            completion = nil
        }
    }

    public func loadImage(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageLoaderDataTask {
        let wrapper = TaskWrapper(completion: completion)
        wrapper.task = client.get(from: url, completion: { [weak self] result in
            guard self != nil else { return }
            
            wrapper.complete(
                with: result
                    .mapError { _ in Error.connection }
                    .flatMap { data, response in
                        if data.isEmpty {
                            return .failure(Error.emptyData)
                        } else if response.statusCode != 200 {
                            return .failure(Error.invalidData)
                        } else {
                            return .success(data)
                        }
                    }
            )
        })
        return wrapper
    }
}
