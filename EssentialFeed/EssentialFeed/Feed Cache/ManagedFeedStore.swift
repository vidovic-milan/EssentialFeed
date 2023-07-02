import CoreData

public class ManagedFeedStore {
    private static let modelName: String = "FeedStore"
    private static let model = NSManagedObjectModel(name: modelName, bundle: Bundle(for: ManagedFeedStore.self))

    public enum ManagedFeedStoreError: Error {
        case invalidModelName
    }

    private let storeURL: URL
    private let context: NSManagedObjectContext
    private let container: NSPersistentContainer

    public init(storeURL: URL) throws {
        guard let model = ManagedFeedStore.model else {
            throw ManagedFeedStoreError.invalidModelName
        }

        self.container = try NSPersistentContainer.load(name: ManagedFeedStore.modelName, model: model, url: storeURL)

        self.storeURL = storeURL
        self.context = container.newBackgroundContext()
    }

    deinit {
        cleanUpReferencesToPersistentStores()
    }

    private func cleanUpReferencesToPersistentStores() {
        context.performAndWait {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }

    func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        context.perform { [context] in action(context) }
    }
}
