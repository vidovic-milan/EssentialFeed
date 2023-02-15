import Foundation

internal struct RemoteFeedMapper {
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

    private static var OK_200: Int { 200 }

    internal static func map(response: HTTPURLResponse, data: Data) throws -> [FeedItem] {
        guard let root = try? JSONDecoder().decode(Root.self, from: data), response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items.map { $0.feedItem }
    }
}
