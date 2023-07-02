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

    // - MARK: LocalFeedLoader

    func test_loadFeed_deliverEmptyFeed() {
        let loadSUT = makeFeedLoader()

        expect(sut: loadSUT, toLoad: [])
    }

    func test_loadFeed_deliversInsertedFeed() {
        let loadSUT = makeFeedLoader()
        let saveSUT = makeFeedLoader()
        let feed = uniqueImageFeed()

        save(feed: feed.models, with: saveSUT)

        expect(sut: loadSUT, toLoad: feed.models)
    }

    func test_loadFeed_deliversLatestFeed() {
        let loadSUT = makeFeedLoader()
        let firstSaveSUT = makeFeedLoader()
        let lastSaveSUT = makeFeedLoader()
        let firstFeed = uniqueImageFeed()
        let lastFeed = uniqueImageFeed()

        save(feed: firstFeed.models, with: firstSaveSUT)
        save(feed: lastFeed.models, with: lastSaveSUT)

        expect(sut: loadSUT, toLoad: lastFeed.models)
    }

    func test_saveFeed_overridesItemsSavedOnASeparateInstance() {
        let feedLoaderToPerformFirstSave = makeFeedLoader()
        let feedLoaderToPerformLastSave = makeFeedLoader()
        let feedLoaderToPerformLoad = makeFeedLoader()
        let firstFeed = uniqueImageFeed().models
        let latestFeed = uniqueImageFeed().models

        save(feed: firstFeed, with: feedLoaderToPerformFirstSave)
        save(feed: latestFeed, with: feedLoaderToPerformLastSave)

        expect(sut: feedLoaderToPerformLoad, toLoad: latestFeed)
    }

    // - MARK: LocalFeedImageDataLoader

    func test_loadImageData_deliversSavedDataOnASeparateInstance() {
        let imageLoaderToPerformSave = makeImageLoader()
        let imageLoaderToPerformLoad = makeImageLoader()
        let feedLoader = makeFeedLoader()
        let image = uniqueImage()
        let dataToSave = anyData()

        save(feed: [image], with: feedLoader)
        save(data: dataToSave, for: image.url, with: imageLoaderToPerformSave)

        expect(sut: imageLoaderToPerformLoad, toLoad: dataToSave, for: image.url)
    }

    func test_saveImageData_overridesSavedImageDataOnASeparateInstance() {
        let imageLoaderToPerformFirstSave = makeImageLoader()
        let imageLoaderToPerformLastSave = makeImageLoader()
        let imageLoaderToPerformLoad = makeImageLoader()
        let feedLoader = makeFeedLoader()
        let image = uniqueImage()
        let firstImageData = Data("first".utf8)
        let lastImageData = Data("last".utf8)

        save(feed: [image], with: feedLoader)
        save(data: firstImageData, for: image.url, with: imageLoaderToPerformFirstSave)
        save(data: lastImageData, for: image.url, with: imageLoaderToPerformLastSave)

        expect(sut: imageLoaderToPerformLoad, toLoad: lastImageData, for: image.url)
    }

    // - MARK: Helpers
    
    private func makeFeedLoader(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let store = try! ManagedFeedStore(storeURL: testSpecificStoreURL())
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return sut
    }

    private func makeImageLoader(file: StaticString = #file, line: UInt = #line) -> LocalFeedImageDataLoader {
        let store = try! ManagedFeedStore(storeURL: testSpecificStoreURL())
        let sut = LocalFeedImageDataLoader(store: store)
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

    private func save(data: Data, for url: URL, with loader: LocalFeedImageDataLoader, file: StaticString = #file, line: UInt = #line) {
        let saveExp = expectation(description: "Wait for save completion")
        loader.save(data: data, for: url) { result in
            if case let Result.failure(error) = result {
                XCTFail("Expected to save image data successfully, got error: \(error)", file: file, line: line)
            }
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
    }

    private func expect(sut: LocalFeedImageDataLoader, toLoad expectedData: Data, for url: URL, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        _ = sut.loadImage(from: url) { result in
            switch result {
            case let .success(loadedData):
                XCTAssertEqual(loadedData, expectedData, file: file, line: line)

            case let .failure(error):
                XCTFail("Expected successful image data result, got \(error) instead", file: file, line: line)
            }

            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    private func anyData() -> Data {
        "data".data(using: .utf8)!
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
