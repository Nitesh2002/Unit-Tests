//
//  URLSssionClientTests.swift
//  LPERRTests
//
//  Created by Nitesh mishra on 11/02/24.
//

import XCTest
@testable import LPERR

final class URLSssionClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startIntercepting()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopIntercepting()
    }
    
    func test_perform_GETRequestWithURL() {
        
        let url = anyURL()
        
        let expection = expectation(description: "Wait for request")
        
        URLProtocolStub.observeRequests { result in
            XCTAssertEqual(result.url, url)
            XCTAssertEqual(result.httpMethod, "GET")
            expection.fulfill()
        }
        
        makeSUT().get(url, completion: {_ in})
        wait(for: [expection], timeout: 1.0)
    }
    
    
    func test_getFromURL_errorWithError() {
        let error = anyNSError()
        let resultError = resultErrorFor(data: nil, response: nil, error: error)
        XCTAssertEqual(resultError?.domain, error.domain)
        XCTAssertEqual(resultError?.code, error.code)
    }
    
    func test_getFromURL_allInvalidResults() {
        
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyURLResponse(), error: nil))
        
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyURLResponse(), error: anyNSError()))
        
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyURLResponse(), error: nil))
        
    }
    
    func test_getFromURL_successWithDataAndResponse() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        
        let receivedResponse = resultSuccessFor(data: data, response: anyHTTPURLResponse(), error: nil)
        
        XCTAssertEqual(receivedResponse?.data, data)
        XCTAssertEqual(receivedResponse?.response.url, response.url)
        XCTAssertEqual(receivedResponse?.response.statusCode, response.statusCode)
        
    }
    
    func test_getFromURL_successWithEmptyDataOnHTTPURLResponseWithNilData() {
        
        let response = anyHTTPURLResponse()
        
        let receivedResponse = resultSuccessFor(data: nil, response: anyHTTPURLResponse(), error: nil)
        
        let emptyData = Data()
        XCTAssertEqual(receivedResponse?.data, emptyData)
        XCTAssertEqual(receivedResponse?.response.url, response.url)
        XCTAssertEqual(receivedResponse?.response.statusCode, response.statusCode)
    }
}

extension URLSssionClientTests {
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
        let sut = URLSssionClient()
        trackMemoryLeak(sut, file:file, line: line )
       // let sut = URLSession.shared
        return sut
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?) -> NSError? {
        
        let result = resultFor(data: data, response: response, error: error)
        
        var resultError: NSError?
        
        switch result {
        case .failure(let error as NSError):
            resultError = error
        default:
            return nil
        }
        return resultError
    }
    
    private func resultSuccessFor(data: Data?, response: URLResponse?, error: Error?) -> (data: Data, response: HTTPURLResponse)? {
        
        let result = resultFor(data: data, response: response, error: error)
        
        
        switch result {
        case .success(let data, let response):
            return (data, response)
        default:
            return nil
        }
    }
    
    private func resultFor(data: Data?, response: URLResponse?, error: Error?) -> HTTPClientResult {
        
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        let expectation  = expectation(description: "Wait for completion")
        var returnedResult: HTTPClientResult!
        
        makeSUT().get(anyURL()) { result in
            returnedResult = result
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        return returnedResult
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://a-test-url")!
    }
    
    private func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 1)
    }
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func anyURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
}


class URLProtocolStub: URLProtocol {
    
    private static var stub : Stub?
    private static var requestObserver: ((URLRequest) -> Void)?
    
    struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }
    
    static func stub(data: Data?, response: URLResponse?, error: Error?) {
        stub = Stub(data: data, response: response, error: error)
    }
    
    static func startIntercepting() {
        URLProtocol.registerClass(URLProtocolStub.self)
    }
    
    static func stopIntercepting() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
        stub = nil
        requestObserver = nil
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        requestObserver?(request)
        return true
    }
    static func observeRequests(completion:@escaping(URLRequest) -> Void) {
        requestObserver = completion
    }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        
        if let data = URLProtocolStub.stub?.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = URLProtocolStub.stub?.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let error = URLProtocolStub.stub?.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        
    }
}
