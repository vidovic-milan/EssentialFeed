import XCTest
import EssentialFeed

class ManagedFeedStoreTests: XCTestCase, FailableFeedStore {
    
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
        let stub = NSManagedObjectContext.alwaysFailingFetch()
        stub.startIntercepting()

        let sut = makeSUT()

        assertRetrievalDeliversFailureOnRetrievalError(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let stub = NSManagedObjectContext.alwaysFailingFetch()
        stub.startIntercepting()

        let sut = makeSUT()

        assertRetrievalHasNoSideEffectsOnError(on: sut)
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()

        assertInsertionOverridesPreviouslyInsertedCacheValues(on: sut)
    }

    func test_insert_doesNotFailOnInsertingNewValues() {
//        let sut = makeSUT()
//
//        assertInsertionDoesNotFailOnInsertingNewValues(on: sut)
    }
    
    func test_insert_deliversErrorOnInsertionError() {
//        let invalidStoreURL = URL(string: "invalid://store-url")!
//        let sut = makeSUT(storeURL: invalidStoreURL)
//
//        assertInsertionDeliversErrorOnInsertionError(on: sut)
    }

    func test_insert_deliversEmptyFeedOnInsertionError() {
//        let invalidStoreURL = URL(string: "invalid://store-url")!
//        let sut = makeSUT(storeURL: invalidStoreURL)
//
//        assertInsertionDeliversErrorOnInsertionError(on: sut)
    }

    func test_delete_completesSuccessfullyOnEmptyCache() {
//        let sut = makeSUT()
//
//        assertDeletionCompletesSuccessfullyOnEmptyCache(on: sut)
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
//        let sut = makeSUT()
//
//        assertDeletionHasNoSideEffectsOnEmptyCache(on: sut)
    }

    func test_delete_completesSuccessfullyOnPreviouslyInsertedCache() {
//        let sut = makeSUT()
//
//        assertDeletionCompletesSuccessfullyOnPreviouslyInsertedCache(on: sut)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
//        let sut = makeSUT()
//
//        assertDeletionEmptiesPreviouslyInsertedCache(on: sut)
    }

    func test_delete_retrievesEmptyFeedOnDeletionError() {
//        let noDeletePermissionURL = cachesDirectory()
//        let sut = makeSUT(storeURL: noDeletePermissionURL)
//
//        assertDeletionRetrievesEmptyFeedOnDeletionError(on: sut)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
//        let noDeletePermissionURL = cachesDirectory()
//        let sut = makeSUT(storeURL: noDeletePermissionURL)
//
//        assertDeletionDeliversErrorOnDeletionError(on: sut)
    }

    func test_sideEffectsOperations_runSerially() {
//        let sut = makeSUT()
//
//        assertSideEffectOperationsRunSerially(on: sut)
    }

    // - MARK: Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
        guard let sut = try? ManagedFeedStore(storeURL: storeURL ?? testSpecificStoreURL()) else {
            fatalError("ManagedFeedStore creation failed")
        }
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
    
}