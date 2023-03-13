import Foundation

protocol FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache()
    func test_retrieve_hasNoSideEffectsOnEmptyCache()
    func test_retrieve_deliversFoundValuesOnNonEmptyCache()
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache()

    func test_insert_overridesPreviouslyInsertedCacheValues()
    func test_insert_doesNotFailOnInsertingNewValues()

    func test_delete_completesSuccessfullyOnEmptyCache()
    func test_delete_hasNoSideEffectsOnEmptyCache()
    func test_delete_completesSuccessfullyOnPreviouslyInsertedCache()
    func test_delete_emptiesPreviouslyInsertedCache()

    func test_sideEffectsOperations_runSerially()
}

protocol FailableRetrieveFeedStoreSpecs: FeedStoreSpecs {
    func test_retrieve_deliversFailureOnRetrievalError()
    func test_retrieve_hasNoSideEffectsOnFailure()
}

protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
    func test_insert_deliversErrorOnInsertionError()
    func test_insert_deliversEmptyFeedOnInsertionError()
}

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
    func test_delete_retrievesEmptyFeedOnDeletionError()
    func test_delete_deliversErrorOnDeletionError()
}
