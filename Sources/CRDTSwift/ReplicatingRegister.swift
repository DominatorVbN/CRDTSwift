//
//  ReplicatingRegister.swift
//
//
//  Created by Amit Samant on 2/7/24.
//

import Foundation

public struct ReplicatingRegister<T> {
    
    // Stores individial unique snapshot of the value and provides info about which record is newer when compared against other
    fileprivate struct Entry: Identifiable {
        var value: T
        var timestamp: TimeInterval
        var id: UUID
        
        init(
            value: T,
            timestamp: TimeInterval = Date().timeIntervalSinceReferenceDate,
            id: UUID = UUID()
        ) {
            self.value = value
            self.timestamp = timestamp
            self.id = id
        }
        
        func isOrdered(after other: Entry) -> Bool {
            (timestamp, id.uuidString) > (other.timestamp, other.id.uuidString)
        }
    }
    
    private var entry: Entry
    
    public var value: T {
        get {
            entry.value
        }
        set {
            // Every time the value is set it will update the id and timestamp making an unique record
            entry = Entry(value: newValue)
        }
    }
    
    public init(_ value: T) {
        self.entry = Entry(value: value)
    }

}

extension ReplicatingRegister: Replicable {
    public func merged(with other: ReplicatingRegister<T>) -> ReplicatingRegister<T> {
        entry.isOrdered(after: other.entry) ? self : other
    }
}

extension ReplicatingRegister: Equatable where T: Equatable {}
 
extension ReplicatingRegister.Entry: Equatable where T: Equatable {}
 
extension ReplicatingRegister: Hashable where T: Hashable {}
 
extension ReplicatingRegister.Entry: Hashable where T: Hashable {}

extension ReplicatingRegister: Codable where T: Codable {}
 
extension ReplicatingRegister.Entry: Codable where T: Codable {}
