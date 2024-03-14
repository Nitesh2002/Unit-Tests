//
//  LocalFeedLoader.swift
//  LPERR
//
//  Created by Nitesh mishra on 13/03/24.
//

import Foundation

public final class LocalFeedLoader {
    
    public typealias SaveResult = Error?
    
    let store: FeedStore
    let currentDate: ()-> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ feed: [LocalFeedItem], completion:@escaping (SaveResult)-> Void) {
        store.deleteCahedFeed { [weak self] error in
            guard let self = self else {
                return
            }
            if let cacheDeleteionError = error {
                completion(cacheDeleteionError)
            } else {
                self.cache(feed, with: completion)
            }
        }
    }
    
    private func cache(_ feed: [LocalFeedItem], with completion: @escaping (SaveResult) -> Void) {
        store.insert(feed, timeStamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            
            completion(error)
        }
    }
}
