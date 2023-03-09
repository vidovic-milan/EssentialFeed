import XCTest
import EssentialFeed

final class EssentialFeedAPIEndToEndTests: XCTestCase {
    func test_endToEndTestServerGETFeedResult_shouldMatchFixedAccountData() {
        switch getFeedResult() {
        case .success(let items)?:
            XCTAssertEqual(items.count, 8, "Expected 8 items in the response list")
            XCTAssertEqual(items[0], expectedItem(at: 0))
            XCTAssertEqual(items[1], expectedItem(at: 1))
            XCTAssertEqual(items[2], expectedItem(at: 2))
            XCTAssertEqual(items[3], expectedItem(at: 3))
            XCTAssertEqual(items[4], expectedItem(at: 4))
            XCTAssertEqual(items[5], expectedItem(at: 5))
            XCTAssertEqual(items[6], expectedItem(at: 6))
            XCTAssertEqual(items[7], expectedItem(at: 7))
        case .failure(let error)?:
            XCTFail("Expected success, got \(error) instead")
        default:
            XCTFail("Expected success, got no result")
        }
    }

    // MARK: - Helpers

    private func getFeedResult() -> LoadFeedResult? {
        let testServerURL = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient()
        let loader = RemoteFeedLoader(client: client, url: testServerURL)
        trackMemoryLeak(client)
        trackMemoryLeak(loader)
        let exp = expectation(description: "wait for remote load")
        var receivedResult: LoadFeedResult?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 13.0)
        return receivedResult
    }

    private func trackMemoryLeak(_ instance: AnyObject, line: UInt = #line, file: StaticString = #filePath) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should be deallocated. Potential memory leak", file: file, line: line)
        }
    }

    private func expectedItem(at index: Int) -> FeedItem {
        return FeedItem(id: id(at: index), description: description(at: index), location: location(at: index), imageURL: imageURL(at: index))
    }

    private func id(at index: Int) -> UUID {
        let ids = [
            UUID(uuidString: "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6")!,
            UUID(uuidString: "BA298A85-6275-48D3-8315-9C8F7C1CD109")!,
            UUID(uuidString: "5A0D45B3-8E26-4385-8C5D-213E160A5E3C")!,
            UUID(uuidString: "FF0ECFE2-2879-403F-8DBE-A83B4010B340")!,
            UUID(uuidString: "DC97EF5E-2CC9-4905-A8AD-3C351C311001")!,
            UUID(uuidString: "557D87F1-25D3-4D77-82E9-364B2ED9CB30")!,
            UUID(uuidString: "A83284EF-C2DF-415D-AB73-2A9B8B04950B")!,
            UUID(uuidString: "F79BD7F8-063F-46E2-8147-A67635C3BB01")!
        ]
        return ids[index]
    }

    private func description(at index: Int) -> String? {
        let descriptions = [
            "Description 1",
            nil,
            "Description 3",
            nil,
            "Description 5",
            "Description 6",
            "Description 7",
            "Description 8"
        ]
        return descriptions[index]
    }

    private func location(at index: Int) -> String? {
        let descriptions = [
            "Location 1",
            "Location 2",
            nil,
            nil,
            "Location 5",
            "Location 6",
            "Location 7",
            "Location 8"
        ]
        return descriptions[index]
    }

    private func imageURL(at index: Int) -> URL {
        let urls = [
            URL(string: "https://url-1.com")!,
            URL(string: "https://url-2.com")!,
            URL(string: "https://url-3.com")!,
            URL(string: "https://url-4.com")!,
            URL(string: "https://url-5.com")!,
            URL(string: "https://url-6.com")!,
            URL(string: "https://url-7.com")!,
            URL(string: "https://url-8.com")!
        ]
        return urls[index]
    }
}
