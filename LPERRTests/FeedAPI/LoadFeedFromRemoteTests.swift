//
//  LoadFeedFromRemoteTests.swift
//  LPERRTests
//
//  Created by Nitesh mishra on 05/02/24.
//

import XCTest
import LPERR

class LoadFeedFromRemoteTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_,client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://stopitcyberbully.atlassian.net/browse/ENG-3108")!
        let (sut, client) = makeSUT(url)
        sut.load{ _  in }
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_requestDataFromURLTwice() {
        let url = URL(string: "https://stopitcyberbully.atlassian.net/browse/ENG-3108")!
        let (sut, client) = makeSUT(url)
        sut.load{ _  in }
        sut.load{ _  in }
        XCTAssertEqual(client.requestedURLs, [url,url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        expect(sut: sut, expectedResult: .failure(RemoteFeedLoader.Error.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPStatusCode() {
        
        let (sut, client) = makeSUT()
        
        let statusCodes = [199,201,300,400,500]
        
        statusCodes.enumerated().forEach { index,code in
            expect(sut: sut, expectedResult: .failure(RemoteFeedLoader.Error.invalidData)) {
                client.complete(withStatusCode: code, data: makeJsonData(items: []), at: index)
            }
        }
    }
    
    func test_load_deliversInvalidJsonDataWith200HTTPStatusCode() {
        
        let (sut, client) = makeSUT()
        expect(sut: sut, expectedResult: .failure(RemoteFeedLoader.Error.invalidData)) {
            let invalidJsonData = Data("invalid".utf8)
            client.complete(withStatusCode: 200, data: invalidJsonData)
        }
    }
    
    func test_load_deliversEmptyJsonDataFeedsWith200HTTPSatusCode() {
        let (sut, client) = makeSUT()
        expect(sut: sut, expectedResult: .success([])) {
            client.complete(withStatusCode: 200, data: makeJsonData(items: []))
        }
    }
    
    func test_load_deliversJsonItemsWoth200HTTPStatusCode() {
        let (sut, client) = makeSUT()
        let allKeyItem = makeFeedItem(id: UUID(), description: "all present", location: "all location", imageURL: URL(string: "https://a-url.com")!)
        let allKeysButDescriptionItem = makeFeedItem(id: UUID(),location: "only location", imageURL: URL(string: "https://b-url.com")!)
        let allKeysButLocationItem = makeFeedItem(id: UUID(), description: "only description", imageURL: URL(string: "https://c-url.com")!)
        let allMandatoryKeysItem = makeFeedItem(id: UUID(), imageURL: URL(string: "https://d-url.com")!)
        
        expect(sut: sut, expectedResult: .success([allKeyItem.model,allKeysButDescriptionItem.model,allKeysButLocationItem.model,allMandatoryKeysItem.model])) {
            
            let jsonData = makeJsonData(items: [allKeyItem.json,allKeysButDescriptionItem.json,allKeysButLocationItem.json,allMandatoryKeysItem.json])
            client.complete(withStatusCode: 200, data: jsonData)
        }
    }
    
    func test_sutCallsEvenAfterItIsDeallocated () {
        
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: URL(string: "https://a-url.com")!, client: client)
    
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load { capturedResults.append($0) }
        
        sut = nil
        
        client.complete(withStatusCode: 200, data: makeJsonData(items: []))
        
        XCTAssertTrue(capturedResults.isEmpty)
        
    }
}

// Helpers
extension LoadFeedFromRemoteTests {
    
    private func expect(sut: RemoteFeedLoader, expectedResult: RemoteFeedLoader.Result, when action:() -> Void, file: StaticString = #file, line: UInt = #line) {
        
        let expectation = expectation(description: "Wait for load")
        
        sut.load { receivedResult in
            
            switch (receivedResult, expectedResult) {
                
            case  let (.success(receivedFeeds), .success(expectedFeeds)):
                XCTAssertEqual(receivedFeeds, expectedFeeds)
                
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError)
                
            default:
                XCTFail("Expect to fail")
            
            }
            expectation.fulfill()
        }
        
        action()
        wait(for: [expectation], timeout: 1.0)
    }
    
    private func makeSUT(_ url: URL = URL(string: "https://stopitcyberbully.atlassian.net/browse/ENG-3109")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client:client)
        trackMemoryLeak(sut)
        trackMemoryLeak(client)
        return (sut, client)
    }
    
    private func makeFeedItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
        
        let model = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].compactMapValues({$0})
        return (model,json)
    }
    
    private func makeJsonData(items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
}

// Spy
extension LoadFeedFromRemoteTests {
    private class HTTPClientSpy: HTTPClient {
        
        func get(_ fromURL: URL, completion: @escaping (LPERR.HTTPClientResult) -> Void) {
            messages.append((fromURL,completion))
        }
        
        private var messages = [(url: URL?, completion:(LPERR.HTTPClientResult)->Void)]()
        
        var requestedURLs: [URL?] {
            messages.map( { $0.url })
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index]!, statusCode: code, httpVersion: nil, headerFields: nil)
            messages[index].completion(.success(data,response!))
        }
    }
}
