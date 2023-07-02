import Foundation

public protocol FeedImageDataStore {
    typealias RetrievalResult = Swift.Result<Data?, Error>
    func retrieve(dataFor url: URL, completion: @escaping (RetrievalResult) -> Void)
}
