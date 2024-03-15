//
//  CacheFeedLoaderTests.swift
//  LPERRTests
//
//  Created by Nitesh mishra on 06/03/24.
//

import XCTest
import LPERR

final class CacheFeedLoaderTests: XCTestCase {
    
    func test_init_DoesnotMessageUponCreation() {
        let (store,_) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestCacheDeletion() {
        let (store,sut) = makeSUT()
        sut.save(uniqueTouplefeed().local) { _ in }
        XCTAssertEqual(store.receivedMessages, [.deleteCaheFeed])
    }
    
    func test_save_doesnotInsertWhenDeletionFailedWithError() {
        let (store,sut) = makeSUT()
        sut.save(uniqueTouplefeed().local) { _ in }
        let error = anyNSError()
        store.completeDelete(with: error)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCaheFeed])
    }
    
    func test_save_requestInsertWhenDeleteSucceeded() {
        let timestamp = Date()
        let (store,sut) = makeSUT { timestamp }
        let feed = uniqueTouplefeed().local
        sut.save(feed) { _ in }
        store.completeDeleteSuccess()
        XCTAssertEqual(store.receivedMessages, [.deleteCaheFeed, .insert(feed, timestamp)])
    }
    
    func test_save_failsUponDeletionError() {
        let (store,sut) = makeSUT()
        let error = anyNSError()
        expect(sut, completewithError: anyNSError()) {
            store.completeDelete(with: error)
        }
    }
    
    func test_save_failsToInsertWithError() {
        let (store,sut) = makeSUT()
        let error = anyNSError()
        expect(sut, completewithError: anyNSError()) {
            store.completeDeleteSuccess()
            store.completeInsertion(with: error)
        }
    }
    
    func test_save_insertionCompletesWithSuceessNoError() {
        
        let (store,sut) = makeSUT()
        expect(sut, completewithError:nil) {
            store.completeDeleteSuccess()
            store.completeInsertionSuccess()
        }
    }
    
    func test_save_shouldNotDeliverErrorOnceInstanceDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResults = [LocalFeedLoader.SaveResult]()
        sut?.save(uniqueTouplefeed().local) { receivedResults.append($0) }
        
        sut = nil
        store.completeDelete(with: anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty)
        
    }
    
    func test_save_shouldNotCcaheandDeliverErrorOnceInstanceDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResults = [LocalFeedLoader.SaveResult]()
        sut?.save(uniqueTouplefeed().local) { receivedResults.append($0) }
        
        
        store.completeDeleteSuccess()
        sut = nil
        store.completeInsertionSuccess()
        
        XCTAssertTrue(receivedResults.isEmpty)
        
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
    
    func expect(_ sut: LocalFeedLoader, completewithError expectedError:(NSError?), with action:()-> Void, file:StaticString = #file, line: UInt = #line) {
        
        var receivedError: Error?
        
        let expectation = expectation(description: "Wait for completion to finish")
        sut.save(uniqueTouplefeed().local) {
            error in
            receivedError = error
            expectation.fulfill()
        }
        action()
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, expectedError)
    }
    
    private func makeSUT(currentDate:@escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (FeedStoreSpy, LocalFeedLoader) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackMemoryLeak(store)
        trackMemoryLeak(sut)
        return (store, sut)
    }
    
    func uniquefeed() -> FeedItem {
        return FeedItem(id: UUID(), description: "Any", location: "Any", imageURL: anyURL())
    }
    
    func uniqueTouplefeed() -> (model:[FeedItem],local:[LocalFeedItem]) {
        let feeds = [FeedItem(id: UUID(), description: "Any", location: "Any", imageURL: anyURL())]
        return (feeds,feeds.toLocal())
    }
    
    func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 1)
    }
    
    private class FeedStoreSpy: FeedStore {
        
        enum ReceivedMessage: Equatable {
            case deleteCaheFeed
            case insert([LocalFeedItem], Date)
        }
        
        typealias DeleteCompletion = (Error?) -> Void
        typealias InsertCompletion = (Error?) -> Void
        
        private(set) var receivedMessages = [ReceivedMessage]()
        
        private var deleteCompletions = [DeleteCompletion]()
        private var insertCompletions = [InsertCompletion]()
        
        func deleteCahedFeed(completion: @escaping(DeleteCompletion)) {
            deleteCompletions.append(completion)
            receivedMessages.append(.deleteCaheFeed)
        }
        
        func completeDelete(with error: Error, at Index:Int = 0) {
            deleteCompletions[Index](error)
        }
        
        func completeDeleteSuccess(at Index:Int = 0) {
            deleteCompletions[Index](nil)
        }
        
        func insert(_ feed: [LocalFeedItem], timeStamp: Date, completion: @escaping InsertCompletion) {
            insertCompletions.append(completion)
            receivedMessages.append(.insert(feed, timeStamp))
        }
        
        func completeInsertion(with error: Error, at Index:Int = 0) {
            insertCompletions[Index](error)
        }
        
        func completeInsertionSuccess(at Index:Int = 0) {
            insertCompletions[Index](nil)
        }
    }
}

extension Array where Element == FeedItem {
    func toLocal() -> [LocalFeedItem] {
        return map { LocalFeedItem(id: $0.id,description: $0.description,location: $0.location, imageURL: $0.imageURL) }
    }
}
