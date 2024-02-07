//
//  ReplicatingSet.swift
//  
//
//  Created by Amit Samant on 2/7/24.
//

import XCTest
@testable import CRDTSwift

final class ReplicatingSetTests: XCTestCase {
    
    var a: ReplicatingSet<Int>!
    var b: ReplicatingSet<Int>!
    
    override func setUp() {
        super.setUp()
        a = .init([1])
        b = .init([2])
    }
    
    func testInitiaCreation() {
        XCTAssertEqual(a.values, Set([1]))
    }
    
    func testMergeOfInitiallyUnrelated() {
        let c = a.merged(with: b)
        XCTAssertEqual(c.values, Set([1,2]))
    }
    
    func testInsertion() {
        a.insert(2)
        XCTAssertEqual(a.values, Set([1,2]))
    }
    
    func testDeletion() {
        a.insert(2)
        XCTAssertEqual(a.values, Set([1,2]))
        a.remove(2)
        XCTAssertEqual(a.values, Set([1]))
    }
    
    func testMergeAndDelete() {
        var c = a.merged(with: b)
        XCTAssertEqual(c.values, Set([1,2]))
        c.remove(1)
        XCTAssertEqual(c.values, Set([2]))
    }
    
    func testAssociativity() {
        let c = ReplicatingSet<Int>([3])
        let d = a.merged(with: b).merged(with: c)
        let e = d.merged(with: a.merged(with: b))
        XCTAssertEqual(d.values, e.values)
    }
    
    func testCommutativity() {
        let c = a.merged(with: b)
        let d = b.merged(with: a)
        XCTAssertEqual(c.values, d.values)
    }
    
    func testIdempotency() {
        let c = a.merged(with: b)
        let d = c.merged(with: b)
        let e = d.merged(with: c)
        XCTAssertEqual(c.values, d.values)
        XCTAssertEqual(c.values, e.values)
    }
    
    func testCodable() {
        let data = try! JSONEncoder().encode(a)
        let d = try! JSONDecoder().decode(ReplicatingSet<Int>.self, from: data)
        XCTAssertEqual(a, d)
    }
}
