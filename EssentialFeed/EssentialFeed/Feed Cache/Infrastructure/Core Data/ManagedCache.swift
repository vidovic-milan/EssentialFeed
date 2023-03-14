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

    static func uniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try find(in: context).map(context.delete)
        return ManagedCache(context: context)
    }

    var localFeed: [LocalFeedImage] {
        feed.array.compactMap { $0 as? ManagedFeedImage }.map { $0.localImage }
    }
}
