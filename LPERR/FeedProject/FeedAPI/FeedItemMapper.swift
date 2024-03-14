//
//  FeedItemMapper.swift
//  LPERR
//
//  Created by Nitesh mishra on 08/02/24.
//

import Foundation

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}

class FeedItemMapper {
    
    private static let OK_200: Int = 200
    
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    static func map(_ data: Data, _ response: HTTPURLResponse)  throws ->  [RemoteFeedItem] {
        guard response.statusCode == OK_200,let root: Root = try? JSONDecoder().decode(Root.self, from: data)  else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
}



