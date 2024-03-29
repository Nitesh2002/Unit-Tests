//
//  FeedItemMapper.swift
//  LPERR
//
//  Created by Nitesh mishra on 08/02/24.
//

import Foundation

class FeeditemMapper {
    
    private static let OK_200: Int = 200
    
    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            FeedItem(id: id,description: description, location:location,imageURL: image)
        }
    }
    
    private struct Root: Decodable {
        
        let items: [Item]
        
        var feeds: [FeedItem] {
            items.map({$0.item})
        }
    }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200,let root: Root = try? JSONDecoder().decode(Root.self, from: data)  else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        return .success(root.feeds)
    }
}
