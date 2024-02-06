//
//  LamportTimestampTests.swift
//  
//
//  Created by Amit Samant on 2/7/24.
//

import XCTest
@testable import CRDTSwift

final class LamportTimestampTests: XCTestCase {
    
    var a: LamportTimestamp!
    var b: LamportTimestamp!
    
    override func setUp() {
        super.setUp()
        a = .init()
        b = .init()
    }
    
    func testTick() {
        a.tick()
        XCTAssertEqual(a.clock, 1)
    }
    
    func testComparision() {
        b.tick()
        let max = max(a, b)
        XCTAssertEqual(max, b)
    }
    
}
