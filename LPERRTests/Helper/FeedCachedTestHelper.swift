//
//  FeedCachedTestHelper.swift
//  LPERRTests
//
//  Created by Nitesh mishra on 20/03/24.
//

import Foundation
import LPERR

func uniqueImage() -> FeedItem {
    return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
}

func uniqueImageFeed() -> (models: [FeedItem], local: [LocalFeedItem]) {
    let models = [uniqueImage(), uniqueImage()]
    let local = models.map { LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) }
    return (models, local)
}

extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
