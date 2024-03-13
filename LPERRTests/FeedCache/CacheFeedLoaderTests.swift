//
//  CacheFeedLoaderTests.swift
//  LPERRTests
//
//  Created by Nitesh mishra on 06/03/24.
//

import XCTest
import LPERR

class FeedStore {
    
    typealias DeleteCompletion = (Error?) -> Void
    
    private var deleteCompletions = [DeleteCompletion]()
    var insertedItems = [(items:[FeedItem], timestamp:Date)]()
    
    var deleteCacheCallCount = 0
    var insertCallCount = 0
    
    func deleteCahedFeed(completion: @escaping(DeleteCompletion)) {
        deleteCacheCallCount += 1
        deleteCompletions.append(completion)
    }
    
    func completeDelete(with error: Error, at Index:Int = 0) {
        deleteCompletions[Index](error)
    }
    
    func completeDeleteSuccess(at Index:Int = 0) {
        deleteCompletions[Index](nil)
    }
    
    func insert(_ items: [FeedItem], timeStamp: Date) {
        insertCallCount += 1
        insertedItems.append((items: items, timestamp: timeStamp))
    }
}

class LocalFeedLoader {
    
    let store: FeedStore
    let currentDate: ()-> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCahedFeed { [unowned self] error in
            if error == nil {
                self.store.insert(items, timeStamp: self.currentDate())
            }
        }
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
    
    func test_save_doesnotInsertWhenDeletionFailedWithError() {
        let (store,sut) = makeSUT()
        let items = [uniqueItems(), uniqueItems()]
        sut.save(items)
        let error = anyNSError()
        store.completeDelete(with: error)
        XCTAssertEqual(store.insertCallCount, 0)
    }
    
    func test_save_requestInsertWhenDeleteSucceeded() {
        let timestamp = Date()
        let (store,sut) = makeSUT { timestamp }
        let items = [uniqueItems(), uniqueItems()]
        sut.save(items)
        store.completeDeleteSuccess()
        XCTAssertEqual(store.insertedItems.count, 1)
        XCTAssertEqual(store.insertedItems.first?.items, items)
        XCTAssertEqual(store.insertedItems.first?.timestamp, timestamp)
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
    
    func makeSUT(currentDate:@escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (FeedStore, LocalFeedLoader) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackMemoryLeak(store)
        trackMemoryLeak(sut)
        return (store, sut)
    }
    
    func uniqueItems() -> FeedItem {
        return FeedItem(id: UUID(), description: "Any", location: "Any", imageURL: anyURL())
    }
    
    func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 1)
    }
}
