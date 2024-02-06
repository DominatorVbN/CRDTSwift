import XCTest
@testable import CRDTSwift

final class ReplicatingRegisterTests: XCTestCase {

    var a: ReplicatingRegister<Int>!
    var b: ReplicatingRegister<Int>!
    
    override func setUp() {
        super.setUp()
        a = .init(1)
        b = .init(2)
    }
    
    func testInitiaCreation() {
        XCTAssertEqual(a.value, 1)
    }
    
    func testSettingValue() {
        a.value = 2
        XCTAssertEqual(a.value, 2)
        a.value = 3
        XCTAssertEqual(a.value, 3)
    }
    
    func testMergeOfInitiallyUnrelated() {
        let c = a.merged(with: b)
        XCTAssertEqual(c.value, 2)
    }
    
    func testLastChangeWin() {
        a.value = 3
        let c = a.merged(with: b)
        XCTAssertEqual(c.value, 3)
    }
    
    func testAssociativity() {
        let c = ReplicatingRegister<Int>(3)
        let d = a.merged(with: b).merged(with: c)
        let e = d.merged(with: a.merged(with: b))
        XCTAssertEqual(d.value, e.value)
    }
    
    func testCommutativity() {
        let c = a.merged(with: b)
        let d = b.merged(with: a)
        XCTAssertEqual(c.value, d.value)
    }
    
    func testIdempotency() {
        let c = a.merged(with: b)
        let d = c.merged(with: b)
        let e = d.merged(with: c)
        XCTAssertEqual(c.value, d.value)
        XCTAssertEqual(c.value, e.value)
    }
    
    func testCodable() {
        let data = try! JSONEncoder().encode(a)
        let d = try! JSONDecoder().decode(ReplicatingRegister<Int>.self, from: data)
        XCTAssertEqual(a, d)
    }
}
