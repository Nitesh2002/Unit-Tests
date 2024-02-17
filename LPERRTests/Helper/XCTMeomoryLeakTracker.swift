//
//  XCTMeomoryLeakTracker.swift
//  LPERRTests
//
//  Created by Nitesh mishra on 14/02/24.
//

import Foundation
import XCTest

extension XCTestCase {
    func trackMemoryLeak(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance could have been deallocated. it is potential memory leak",file: file,line: line)
        }
    }
}
