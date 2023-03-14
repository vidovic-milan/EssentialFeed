import CoreData

extension NSManagedObjectContext {
    static func alwaysFailingFetch() -> Stub {
        Stub(
            source: #selector(NSManagedObjectContext.__execute(_:)),
            destination: #selector(Stub.execute)
        )
    }
}

class Stub {
    private let source: Selector
    private let destination: Selector
    init(source: Selector, destination: Selector) {
        self.source = source
        self.destination = destination
    }

    @objc func execute(_: Any) throws -> Any {
        throw anyNSError()
    }

    @objc func save() throws {
        throw anyNSError()
    }

    func startIntercepting() {
        method_exchangeImplementations(
            class_getInstanceMethod(NSManagedObjectContext.self, source)!,
            class_getInstanceMethod(Stub.self, destination)!
        )
    }

    func stopIntercepting() {
        method_exchangeImplementations(
            class_getInstanceMethod(Stub.self, destination)!,
            class_getInstanceMethod(NSManagedObjectContext.self, source)!
        )
    }

    deinit {
       stopIntercepting()
    }
}
