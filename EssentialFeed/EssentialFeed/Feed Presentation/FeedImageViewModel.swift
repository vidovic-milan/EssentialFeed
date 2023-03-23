import Foundation

public struct FeedImageViewModel<Image> {
    public let location: String?
    public let description: String?
    public let isLocationHidden: Bool
    public let loadedImage: Image?
    public let shouldRetry: Bool
    public let isLoading: Bool
}
