//
//  ReplicatingSet.swift
//  
//
//  Created by Amit Samant on 2/7/24.
//

import Foundation

public struct ReplicatingSet<T: Hashable> {
    
    fileprivate struct Metadata {
        var isDeleted: Bool
        var lamportTimeStamp: LamportTimestamp
        
        init(lamportTimeStamp: LamportTimestamp) {
            self.isDeleted = false
            self.lamportTimeStamp = lamportTimeStamp
        }
    }
    
    private var metadataByValue: Dictionary<T,Metadata>
    private var currentTimestamp: LamportTimestamp
    
    public init() {
        self.metadataByValue = .init()
        self.currentTimestamp = .init()
    }
    
    public init(array: [T]) {
        self = .init()
        array.forEach { self.insert($0) }
    }
    
    @discardableResult
    public mutating func insert(_ value: T) -> Bool {
        
        currentTimestamp.tick()
        
        let metadata = Metadata(lamportTimeStamp: currentTimestamp)
        let isNewInsert: Bool
        
        if let existingMetadata = metadataByValue[value] {
            isNewInsert = existingMetadata.isDeleted
        } else {
            isNewInsert = true
        }
        
        metadataByValue[value] = metadata
        
        return isNewInsert
    }
    
    @discardableResult
    public mutating func remove(_ value: T) -> T? {
        let returnValue: T?
        if let existingMetadata = metadataByValue[value], !existingMetadata.isDeleted {
            currentTimestamp.tick()
            var metadata = Metadata(lamportTimeStamp: currentTimestamp)
            metadata.isDeleted = true
            metadataByValue[value] = metadata
            returnValue = value
        } else {
            returnValue = nil
        }
        return returnValue
    }
    
    public var values: Set<T> {
        let values = metadataByValue
            .filter { !$1.isDeleted }
            .map { $0.key }
        return Set(values)
    }
    
    public func contains(_ value: T) -> Bool {
        !(metadataByValue[value]?.isDeleted ?? true)
    }
}

extension ReplicatingSet: Replicable {
    
    public func merged(with other: ReplicatingSet<T>) -> ReplicatingSet<T> {
        var result = self
        result.metadataByValue = other.metadataByValue.reduce(into: metadataByValue, { partialResult, entry in
            let firstMetadata = partialResult[entry.key]
            let secondMetadata = entry.value
            
            if let firstMetadata = firstMetadata {
                partialResult[entry.key] = firstMetadata.lamportTimeStamp > secondMetadata.lamportTimeStamp ? firstMetadata : secondMetadata
            } else {
                partialResult[entry.key] = secondMetadata
            }
            
        })
        result.currentTimestamp = max(self.currentTimestamp, other.currentTimestamp)
        return result
    }
}


extension ReplicatingSet: Codable where T: Codable {}

extension ReplicatingSet.Metadata: Codable {}
extension ReplicatingSet.Metadata: Equatable {}

extension ReplicatingSet: Equatable where T: Equatable {}
