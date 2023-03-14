import Foundation
import CoreData

@objc(ManagedFeedImage)
class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var location: String?
    @NSManaged var imageDescription: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
}

extension ManagedFeedImage {
    static func image(from local: LocalFeedImage, in context: NSManagedObjectContext) -> ManagedFeedImage {
        let managedImage = ManagedFeedImage(context: context)
        managedImage.id = local.id
        managedImage.location = local.location
        managedImage.imageDescription = local.description
        managedImage.url = local.url
        return managedImage
    }

    var localImage: LocalFeedImage {
        return LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
    }
}
