//
//  SahredTestHelper.swift
//  LPERRTests
//
//  Created by Nitesh mishra on 20/03/24.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}
