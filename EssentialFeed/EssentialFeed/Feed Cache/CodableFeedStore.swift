import Foundation

public class CodableFeedStore: FeedStore {
	private struct Cache: Codable {
		let feed: [CodableFeedImage]
		let timestamp: Date
		
		var localFeed: [LocalFeedImage] {
			return feed.map { $0.local }
		}
	}
	
	private struct CodableFeedImage: Codable {
		private let id: UUID
		private let description: String?
		private let location: String?
		private let url: URL
		
		init(_ image: LocalFeedImage) {
			id = image.id
			description = image.description
			location = image.location
			url = image.url
		}
		
		var local: LocalFeedImage {
			return LocalFeedImage(id: id, description: description, location: location, url: url)
		}
	}
	
	private let storeURL: URL
    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
	
	public init(storeURL: URL) {
		self.storeURL = storeURL
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
        let storeURL = storeURL
        queue.async {
            completion(
                Result {
                    guard let data = try? Data(contentsOf: storeURL) else {
                        return .none
                    }
                    let decoder = JSONDecoder()
                    let cache = try decoder.decode(Cache.self, from: data)
                    return (feed: cache.localFeed, timestamp: cache.timestamp)
                }
            )
        }
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        let storeURL = storeURL
        queue.async(flags: .barrier) {
            completion(
                Result {
                    let encoder = JSONEncoder()
                    let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
                    let encoded = try encoder.encode(cache)
                    try encoded.write(to: storeURL)
                }
            )
        }
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let storeURL = storeURL
        queue.async(flags: .barrier) {
            completion(
                Result {
                    guard FileManager.default.fileExists(atPath: storeURL.path) else { return }
                    try FileManager.default.removeItem(at: storeURL)
                }
            )
        }
	}
}
