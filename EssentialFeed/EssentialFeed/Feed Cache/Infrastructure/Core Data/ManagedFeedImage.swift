import Foundation
import CoreData

@objc(ManagedFeedImage)
class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var location: String?
    @NSManaged var imageDescription: String?
    @NSManaged var data: Data?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
}

extension ManagedFeedImage {

    static func first(with url: URL, in context: NSManagedObjectContext) throws -> ManagedFeedImage? {
        let request = NSFetchRequest<ManagedFeedImage>(entityName: entity().name!)
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(ManagedFeedImage.url), url])
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

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
