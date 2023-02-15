import Foundation

public final class RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }

    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }

    public func load(completion: @escaping (RemoteFeedLoader.Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(response, data): completion(self.map(response, data: data))
            case .failure: completion(.failure(.connectivity))
            }
        }
    }

    internal func map(_ response: HTTPURLResponse, data: Data) -> Result {
        do {
            let items = try RemoteFeedMapper.map(response: response, data: data)
            return .success(items)
        } catch {
            return .failure(.invalidData)
        }
    }
}
