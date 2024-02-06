//
//  ReplicatingAddOnlySet.swift
//  
//
//  Created by Amit Samant on 2/7/24.
//

import Foundation

public struct ReplicatingAddOnlySet<T: Hashable> {
    
    private var storage: Set<T>
    
    public mutating func insert(_ entry: T) {
        storage.insert(entry)
    }
    
    public var values: Set<T> {
        return storage
    }
    
    public init() {
        storage = .init()
    }
    
    public init(_ values: Set<T>) {
        storage = values
    }
    
}

extension ReplicatingAddOnlySet: Replicable {
    public func merged(with other: ReplicatingAddOnlySet<T>) -> ReplicatingAddOnlySet<T> {
        ReplicatingAddOnlySet(storage.union(other.storage))
    }
}

extension ReplicatingAddOnlySet: Equatable where T: Equatable {}
  
extension ReplicatingAddOnlySet: Hashable where T: Hashable {}
 
extension ReplicatingAddOnlySet: Codable where T: Codable {}
 
