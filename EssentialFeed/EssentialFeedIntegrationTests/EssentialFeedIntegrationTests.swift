import XCTest
import EssentialFeed

final class EssentialFeedIntegrationTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }

    func test_load_deliverEmptyFeed() {
        let loadSUT = makeSUT()

        expect(sut: loadSUT, toLoad: [])
    }

    func test_load_deliversInsertedFeed() {
        let loadSUT = makeSUT()
        let saveSUT = makeSUT()
        let feed = uniqueImageFeed()

        save(feed: feed.models, with: saveSUT)

        expect(sut: loadSUT, toLoad: feed.models)
    }

    func test_load_deliversLatestFeed() {
        let loadSUT = makeSUT()
        let firstSaveSUT = makeSUT()
        let lastSaveSUT = makeSUT()
        let firstFeed = uniqueImageFeed()
        let lastFeed = uniqueImageFeed()

        save(feed: firstFeed.models, with: firstSaveSUT)
        save(feed: lastFeed.models, with: lastSaveSUT)

        expect(sut: loadSUT, toLoad: lastFeed.models)
    }

    // - MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let store = try! ManagedFeedStore(storeURL: testSpecificStoreURL())
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return sut
    }

    private func save(feed: [FeedImage], with loader: LocalFeedLoader, file: StaticString = #file, line: UInt = #line) {
        let saveExp = expectation(description: "wait for save")
        loader.save(feed) { _ in
            saveExp.fulfill()
        }

        wait(for: [saveExp], timeout: 5.0)
    }

    private func expect(sut loader: LocalFeedLoader, toLoad feed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        let loadExp = expectation(description: "wait for load")
        loader.load { result in
            switch result {
            case .success(let receivedFeed):
                XCTAssertEqual(receivedFeed, feed)
            case .failure(let error):
                XCTFail("Expected to load last feed, got \(error) instead")
            }
            loadExp.fulfill()
        }
        wait(for: [loadExp], timeout: 5.0)
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
