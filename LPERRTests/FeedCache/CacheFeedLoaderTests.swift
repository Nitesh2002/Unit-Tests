//
//  CacheFeedLoaderTests.swift
//  LPERRTests
//
//  Created by Nitesh mishra on 06/03/24.
//

import XCTest
import LPERR

class FeedStore {
    var deleteCacheCallCount = 0
    
    func deleteCahedFeed() {
        deleteCacheCallCount += 1
    }
}

class LocalFeedLoader {
    
    let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCahedFeed()
    }
}

final class CacheFeedLoaderTests: XCTestCase {
    
    func test_init_DoesnotDeleteCacheUponCreation() {
        let (store,_) = makeSUT()
        XCTAssertEqual(store.deleteCacheCallCount, 0)
    }
    
    func test_save_requestCacheDeletion() {
        let (store,sut) = makeSUT()
        let items = [uniqueItems(), uniqueItems()]
        sut.save(items)
        XCTAssertEqual(store.deleteCacheCallCount, 1)
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

extension CacheFeedLoaderTests {
    
    func makeSUT() -> (FeedStore, LocalFeedLoader) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        return (store, sut)
    }
    
    func uniqueItems() -> FeedItem {
        return FeedItem(id: UUID(), description: "Any", location: "Any", imageURL: anyURL())
    }
    
    func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
}
