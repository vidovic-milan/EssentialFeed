import Foundation

public protocol FeedImageLoaderDataTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImage(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageLoaderDataTask
}
