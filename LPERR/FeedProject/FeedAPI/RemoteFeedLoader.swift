//
//  RemoteFeedLoader.swift
//  LPERR
//
//  Created by Nitesh mishra on 05/02/24.
//

import Foundation
 
public final class RemoteFeedLoader: FeedLoader {

    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadFeedResult
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        
        client.get(url) { [weak self] result in
            
            guard self != nil else {
                return
            }
            
            switch result {
            case .success(let data, let response):
                completion(FeeditemMapper.map(data, response))
            case .failure:
                completion(.failure(RemoteFeedLoader.Error.connectivity))
            }
        }
    }
}
