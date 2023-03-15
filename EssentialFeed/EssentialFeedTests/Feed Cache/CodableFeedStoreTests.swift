import XCTest
import EssentialFeed

typealias FailableFeedStore = FailableRetrieveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs

class CodableFeedStoreTests: XCTestCase, FailableFeedStore {
	
	override func setUp() {
		super.setUp()
		
		setupEmptyStoreState()
	}
	
	override func tearDown() {
		super.tearDown()
		
		undoStoreSideEffects()
	}
	
	func test_retrieve_deliversEmptyOnEmptyCache() {
		let sut = makeSUT()

        assertRetrievalReturnsEmptyCache(on: sut)
	}
	
	func test_retrieve_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()
		
        assertRetrievalTwiceReturnsEmptyCache(on: sut)
	}

	func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
		let sut = makeSUT()

        assertRetrievalDeliversFoundValuesOnEmptyCache(on: sut)
	}
	
	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
		let sut = makeSUT()

        assertRetrievalHasNoSideEffectsOnNonEmptyCache(on: sut)
	}
	
	func test_retrieve_deliversFailureOnRetrievalError() {
		let storeURL = testSpecificStoreURL()
		let sut = makeSUT(storeURL: storeURL)
		
		try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
		
        assertRetrievalDeliversFailureOnRetrievalError(on: sut)
	}
	
	func test_retrieve_hasNoSideEffectsOnFailure() {
		let storeURL = testSpecificStoreURL()
		let sut = makeSUT(storeURL: storeURL)
		
		try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
		
        assertRetrievalHasNoSideEffectsOnError(on: sut)
	}
	
	func test_insert_overridesPreviouslyInsertedCacheValues() {
		let sut = makeSUT()

        assertInsertionOverridesPreviouslyInsertedCacheValues(on: sut)
	}

    func test_insert_doesNotFailOnInsertingNewValues() {
        let sut = makeSUT()
        
        assertInsertionDoesNotFailOnInsertingNewValues(on: sut)
    }
	
	func test_insert_deliversErrorOnInsertionError() {
		let invalidStoreURL = URL(string: "invalid://store-url")!
		let sut = makeSUT(storeURL: invalidStoreURL)
		
        assertInsertionDeliversErrorOnInsertionError(on: sut)
	}

    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)

        assertInsertionDeliversEmptyFeedOnInsertionError(on: sut)
    }

    func test_delete_completesSuccessfullyOnEmptyCache() {
        let sut = makeSUT()
        
        assertDeletionCompletesSuccessfullyOnEmptyCache(on: sut)
    }
	
	func test_delete_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()
		
        assertDeletionHasNoSideEffectsOnEmptyCache(on: sut)
	}

    func test_delete_completesSuccessfullyOnPreviouslyInsertedCache() {
        let sut = makeSUT()

        assertDeletionCompletesSuccessfullyOnPreviouslyInsertedCache(on: sut)
    }
	
	func test_delete_emptiesPreviouslyInsertedCache() {
		let sut = makeSUT()

        assertDeletionEmptiesPreviouslyInsertedCache(on: sut)
	}

    func test_delete_hasNoSideEffectsOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory().appendingPathComponent("file.txt")
        try? FileManager.default.removeItem(at: noDeletePermissionURL)

        FileManager.default.createFile(atPath: noDeletePermissionURL.path, contents: "a".data(using: .utf8), attributes: [.posixPermissions:  NSNumber(value: 0o000), .busy: NSNumber(value: 1), .immutable: NSNumber(value: 1), .appendOnly: NSNumber(value: 1)])

        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        assertDeletionRetrievesEmptyFeedOnDeletionError(on: sut)
        
        try! FileManager.default.setAttributes([.posixPermissions: NSNumber(value: 0o666), .busy: NSNumber(value: 0), .immutable: NSNumber(value: 0), .appendOnly: NSNumber(value: 0)], ofItemAtPath: noDeletePermissionURL.path)
        try! FileManager.default.removeItem(at: noDeletePermissionURL)
    }
	
	func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory().appendingPathComponent("file.txt")
        try? FileManager.default.removeItem(at: noDeletePermissionURL)

        FileManager.default.createFile(atPath: noDeletePermissionURL.path, contents: "a".data(using: .utf8), attributes: [.posixPermissions:  NSNumber(value: 0o000), .busy: NSNumber(value: 1), .immutable: NSNumber(value: 1), .appendOnly: NSNumber(value: 1)])

        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        assertDeletionDeliversErrorOnDeletionError(on: sut)
        
        try! FileManager.default.setAttributes([.posixPermissions: NSNumber(value: 0o666), .busy: NSNumber(value: 0), .immutable: NSNumber(value: 0), .appendOnly: NSNumber(value: 0)], ofItemAtPath: noDeletePermissionURL.path)
        try! FileManager.default.removeItem(at: noDeletePermissionURL)
	}

    func test_sideEffectsOperations_runSerially() {
        let sut = makeSUT()

        assertSideEffectOperationsRunSerially(on: sut)
    }

	// - MARK: Helpers
	
	private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
		let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}
	
	private func setupEmptyStoreState() {
		deleteStoreArtifacts()
	}
	
	private func undoStoreSideEffects() {
		deleteStoreArtifacts()
	}
	
	private func deleteStoreArtifacts() {
		try? FileManager.default.removeItem(at: testSpecificStoreURL())
	}
	
	private func testSpecificStoreURL() -> URL {
		return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
	}
	
	private func cachesDirectory() -> URL {
		return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
	}

    private func noDeletePermissionURL() -> URL {
        let path = cachesDirectory().appendingPathComponent("file.txt")

        FileManager.default.createFile(atPath: path.path, contents: "a".data(using: .utf8), attributes: [.posixPermissions:  NSNumber(value: 0o000), .busy: NSNumber(value: 1), .immutable: NSNumber(value: 1), .appendOnly: NSNumber(value: 1)])
        try! FileManager.default.setAttributes([.posixPermissions: NSNumber(value: 0o666), .busy: NSNumber(value: 0), .immutable: NSNumber(value: 0), .appendOnly: NSNumber(value: 0)], ofItemAtPath: path.path)
        try! FileManager.default.removeItem(at: path)
        return path
    }
	
}
