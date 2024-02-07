//
//  ReplicatingDictionaryTests.swift
//  
//
//  Created by Amit Samant on 2/8/24.
//

import XCTest
@testable import CRDTSwift

final class ReplicatingDictionaryTests: XCTestCase {
    
    var dictOfSetsA: ReplicatingDictionary<String,ReplicatingSet<Int>>!
    var dictOfSetsB: ReplicatingDictionary<String,ReplicatingSet<Int>>!
    
    override func setUp() {
        super.setUp()
        
        dictOfSetsA = .init()
        dictOfSetsB = .init()
    }
    
    func testNonAtomicMergingOfReplicatingValues() {
        
        dictOfSetsA["1"] = .init(array: [1,2,3])
        dictOfSetsB["2"] = .init(array: [3,4,5])
        dictOfSetsA["3"] = .init(array: [1])
        
        dictOfSetsB["1"] = .init(array: [1,2,3,4])
        dictOfSetsB["3"] = .init(array: [3,4,5])
        dictOfSetsB["1"] = nil
        dictOfSetsB["3"]!.insert(6)
        
        let dictOfSetC = dictOfSetsA.merged(with: dictOfSetsB)
        let dictOfSetD = dictOfSetsB.merged(with: dictOfSetsA)
        XCTAssertEqual(dictOfSetC["3"]!.values, [1,3,4,5,6])
        XCTAssertNil(dictOfSetC["1"])
        XCTAssertEqual(dictOfSetC["2"]!.values, [3,4,5])
        
        let valuesC = dictOfSetC.values.flatMap({ $0.values }).sorted()
        let valuesD = dictOfSetD.values.flatMap({ $0.values }).sorted()
        XCTAssertEqual(valuesC, valuesD)
        
    }

}
