//
//  LoadFeedFromCacheTests.swift
//  LPERRTests
//
//  Created by Nitesh mishra on 14/03/24.
//

import XCTest
import LPERR

final class LoadFeedFromCacheTests: XCTestCase {
    
    func test_init_DoesnotMessageUponCreation() {
        let (store,_) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    private func makeSUT(currentDate:@escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (FeedStoreSpy, LocalFeedLoader) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackMemoryLeak(store)
        trackMemoryLeak(sut)
        return (store, sut)
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
