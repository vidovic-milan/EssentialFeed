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
        client.get(from: url) { result in
            switch result {
            case let .success(response, data):
                do {
                    let items = try RemoteFeedMapper.map(response: response, data: data)
                    completion(.success(items))
                } catch {
                    completion(.failure(.invalidData))
                }
            case .failure: completion(.failure(.connectivity))
            }
        }
    }
}

private struct RemoteFeedMapper {
    private struct Root: Decodable {
        let items: [Item]
    }

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL

        var feedItem: FeedItem { FeedItem(id: id, description: description, location: location, imageURL: image) }

        init(id: UUID, description: String?, location: String?, image: URL) {
            self.id = id
            self.description = description
            self.location = location
            self.image = image
        }
    }

    static var OK_200: Int { 200 }

    static func map(response: HTTPURLResponse, data: Data) throws -> [FeedItem] {
        guard let root = try? JSONDecoder().decode(Root.self, from: data), response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items.map { $0.feedItem }
    }
}

public enum HTTPClientResponse {
    case success(HTTPURLResponse, Data)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResponse) -> Void)
}
