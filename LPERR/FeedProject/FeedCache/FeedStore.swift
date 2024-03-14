//
//  FeedStore.swift
//  LPERR
//
//  Created by Nitesh mishra on 14/03/24.
//

import Foundation

public protocol FeedStore {
    typealias DeleteCompletion = (Error?) -> Void
    typealias InsertCompletion = (Error?) -> Void
    
    func deleteCahedFeed(completion: @escaping(DeleteCompletion))
    func insert(_ feed: [LocalFeedItem], timeStamp: Date, completion: @escaping InsertCompletion)
}
