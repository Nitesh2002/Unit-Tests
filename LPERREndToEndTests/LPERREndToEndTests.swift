//
//  LPERREndToEndTests.swift
//  LPERREndToEndTests
//
//  Created by Nitesh mishra on 16/02/24.
//

import XCTest
import LPERR

final class LPERREndToEndTests: XCTestCase {

//    func demo() {
//        let cache = URLCache(memoryCapacity: 20*1000*1000, diskCapacity: 50*1000*1000)
//        let config = URLSessionConfiguration.default
//        config.urlCache = cache
//        config.requestCachePolicy = .reloadIgnoringLocalCacheData
//        let session = URLSession(configuration: config)
//        let request = URLRequest(url: URL("https://a-url.com/")!,cachePolicy: .returnCacheDataDontLoad,timeoutInterval: 400000)
//    }
    
    func test_EndtoEndServerResults_matchesTheTestAccountData() {
        
        switch getFeedResults() {
        case .success(let feeds):
            XCTAssertEqual(feeds.count, 8)
            XCTAssertEqual(feeds[0], expectedItem(at: 0))
            XCTAssertEqual(feeds[1], expectedItem(at: 1))
            XCTAssertEqual(feeds[2], expectedItem(at: 2))
            XCTAssertEqual(feeds[3], expectedItem(at: 3))
            XCTAssertEqual(feeds[4], expectedItem(at: 4))
            XCTAssertEqual(feeds[5], expectedItem(at: 5))
            XCTAssertEqual(feeds[6], expectedItem(at: 6))
            XCTAssertEqual(feeds[7], expectedItem(at: 7))
        case .failure(let error):
            XCTFail("Expected success result got \(String(describing: error)) instread")
        default:
            XCTFail("Expected success result got no result instread")
        }
        
    }
    
    private func getFeedResults(file: StaticString = #file, line: UInt = #line) -> LoadFeedResult? {
        let url = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSssionClient()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        trackMemoryLeak(client,file: file, line: line)
        trackMemoryLeak(sut,file: file, line: line)
        
        let expectation = expectation(description: "Wait for load completion")
        var receivedfeedResult: LoadFeedResult?
        
        sut.load { result in
            receivedfeedResult = result
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
        return receivedfeedResult
    }

    private func expectedItem(at index: Int) -> FeedItem {
            return FeedItem(
                id: id(at: index),
                description: description(at: index),
                location: location(at: index),
                imageURL: imageURL(at: index))
        }

        private func id(at index: Int) -> UUID {
            return UUID(uuidString: [
                "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
                "BA298A85-6275-48D3-8315-9C8F7C1CD109",
                "5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
                "FF0ECFE2-2879-403F-8DBE-A83B4010B340",
                "DC97EF5E-2CC9-4905-A8AD-3C351C311001",
                "557D87F1-25D3-4D77-82E9-364B2ED9CB30",
                "A83284EF-C2DF-415D-AB73-2A9B8B04950B",
                "F79BD7F8-063F-46E2-8147-A67635C3BB01"
            ][index])!
        }

        private func description(at index: Int) -> String? {
            return [
                "Description 1",
                nil,
                "Description 3",
                nil,
                "Description 5",
                "Description 6",
                "Description 7",
                "Description 8"
            ][index]
        }

        private func location(at index: Int) -> String? {
            return [
                "Location 1",
                "Location 2",
                nil,
                nil,
                "Location 5",
                "Location 6",
                "Location 7",
                "Location 8"
            ][index]
        }

        private func imageURL(at index: Int) -> URL {
            return URL(string: "https://url-\(index+1).com")!
        }
}
