import XCTest

extension XCTestCase {
    func trackMemoryLeak(_ instance: AnyObject, line: UInt = #line, file: StaticString = #filePath) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should be deallocated. Potential memory leak", file: file, line: line)
        }
    }

    func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
}
