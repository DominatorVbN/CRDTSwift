//
//  LamportTimestamp.swift
//
//
//  Created by Amit Samant on 2/7/24.
//

import Foundation

public struct LamportTimestamp: Identifiable {
    
    var clock: UInt64 = 0    
    public var id: UUID
    
    public mutating func tick() {
        clock += 1
    }
    
    public init(clock: UInt64 = 0) {
        self.id = .init()
        self.clock = clock
    }
}

extension LamportTimestamp: CustomStringConvertible {
    public var description: String {
        "LamportTimestamp<\(clock),\(id.uuidString)>"
    }
}


extension LamportTimestamp: Comparable {    
    public static func < (lhs: LamportTimestamp, rhs: LamportTimestamp) -> Bool {
        (lhs.clock, lhs.id.uuidString) < (rhs.clock, rhs.id.uuidString)
    }
    
}

extension LamportTimestamp: Codable {}
extension LamportTimestamp: Equatable {}
