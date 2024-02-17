//
//  FeedLoader.swift
//  LPERR
//
//  Created by Nitesh mishra on 03/02/24.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion:@escaping (LoadFeedResult) -> Void)
}
