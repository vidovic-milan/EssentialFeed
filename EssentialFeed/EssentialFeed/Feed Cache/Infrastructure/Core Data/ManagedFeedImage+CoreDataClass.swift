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
