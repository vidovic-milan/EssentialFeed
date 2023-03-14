import CoreData

extension NSManagedObjectModel {
    convenience init?(name: String, bundle: Bundle) {
        guard let url = bundle.url(forResource: name, withExtension: "momd") else {
            return nil
        }
        self.init(contentsOf: url)
    }
}
