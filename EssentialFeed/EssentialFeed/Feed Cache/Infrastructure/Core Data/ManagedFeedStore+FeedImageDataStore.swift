import Foundation

extension ManagedFeedStore: FeedImageDataStore {

    public func insert(data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        perform { context in
            completion(Result {
                try? ManagedFeedImage.first(with: url, in: context)
                    .map { $0.data = data }
                    .map { try? context.save() }
            })
        }
    }

    public func retrieve(dataFor url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        perform { context in
            completion(.success(try? ManagedFeedImage.first(with: url, in: context)?.data))
        }
    }

}
