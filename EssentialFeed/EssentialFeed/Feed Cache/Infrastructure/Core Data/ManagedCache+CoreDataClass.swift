import Foundation
import CoreData

@objc(ManagedCache)
class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}

extension ManagedCache {
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        return try context.fetch(NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)).first
    }
}