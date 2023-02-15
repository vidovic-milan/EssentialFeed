import Foundation

internal struct RemoteFeedMapper {
    private struct Root: Decodable {
        let items: [Item]

        var feedItems: [FeedItem] { items.map { $0.feedItem } }
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

    private static var OK_200: Int { 200 }

    internal static func map(_ response: HTTPURLResponse, data: Data) -> RemoteFeedLoader.Result {
        guard let root = try? JSONDecoder().decode(Root.self, from: data), response.statusCode == OK_200 else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        return .success(root.feedItems)
    }
}
