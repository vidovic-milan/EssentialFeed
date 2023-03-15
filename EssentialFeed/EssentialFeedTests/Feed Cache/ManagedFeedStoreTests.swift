import XCTest
import EssentialFeed

class ManagedFeedStoreTests: XCTestCase, FailableFeedStore {
    
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
        let sut = makeSUT()

        assertInsertionDoesNotFailOnInsertingNewValues(on: sut)
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let stub = NSManagedObjectContext.alwaysFailingSave()
        stub.startIntercepting()

        let sut = makeSUT()

        assertInsertionDeliversErrorOnInsertionError(on: sut)
    }

    func test_insert_hasNoSideEffectsOnInsertionError() {
        let stub = NSManagedObjectContext.alwaysFailingSave()
        stub.startIntercepting()

        let sut = makeSUT()

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
    
    func test_delete_deliversErrorOnDeletionError() {
        let stub = NSManagedObjectContext.alwaysFailingSave()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        let sut = makeSUT()

        insert((feed, timestamp), to: sut)

        stub.startIntercepting()

        let deletionError = deleteCache(from: sut)

        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
    }

    func test_delete_hasNoSideEffectsOnDeletionError() {
        let stub = NSManagedObjectContext.alwaysFailingSave()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        let sut = makeSUT()

        insert((feed, timestamp), to: sut)

        stub.startIntercepting()

        deleteCache(from: sut)

        expect(sut, toRetrieve: .success(.some((feed: feed, timestamp: timestamp))))
    }

    func test_sideEffectsOperations_runSerially() {
        let sut = makeSUT()

        assertSideEffectOperationsRunSerially(on: sut)
    }

    // - MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedStore {
        guard let sut = try? ManagedFeedStore(storeURL: inMemoryStoreURL()) else {
            fatalError("ManagedFeedStore creation failed")
        }
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func inMemoryStoreURL() -> URL {
        URL(fileURLWithPath: "/dev/null")
            .appendingPathComponent("\(type(of: self)).store")
    }
    
}
