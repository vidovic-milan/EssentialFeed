import Foundation

struct FeedImageViewMode<Image> {
    let location: String?
    let description: String?
    let isLocationHidden: Bool
    let loadedImage: Image?
    let shouldRetry: Bool
    let isLoading: Bool
}
