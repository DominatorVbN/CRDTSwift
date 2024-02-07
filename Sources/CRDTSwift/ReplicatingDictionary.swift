//
//  File.swift
//  
//
//  Created by Amit Samant on 2/7/24.
//

import Foundation

struct ReplicatingDictionary<Key: Hashable, Value> {
    
    fileprivate struct ValueContainer {
        
        var isDeleted: Bool
        var lamportTimestamp: LamportTimestamp
        var value: Value
        
        init(value: Value, lamportTimestamp: LamportTimestamp) {
            self.value = value
            self.lamportTimestamp = lamportTimestamp
            self.isDeleted = false
        }
    }
    
    private var valueContainerByKey: Dictionary<Key, ValueContainer>
    private var currentTimestamp: LamportTimestamp
    
    public var values: [Value] {
        valueContainerByKey.map { $0.value.value }
    }
    
    public var keys: [Key] {
        valueContainerByKey.map { $0.key }
    }
    
    subscript(_ key: Key) -> Value? {
        get {
            guard let valueContainer = valueContainerByKey[key], !valueContainer.isDeleted else {
                return nil
            }
            return valueContainer.value
        }
        set {
            currentTimestamp.tick()
            if let newValue = newValue {
                let newContainer = ValueContainer(value: newValue, lamportTimestamp: currentTimestamp)
                valueContainerByKey[key] = newContainer
            } else if let oldContainer = valueContainerByKey[key] {
                var newContainer = ValueContainer(value: oldContainer.value, lamportTimestamp: currentTimestamp)
                newContainer.isDeleted = true
                valueContainerByKey[key] = newContainer
            }
        }
    }
    
    init() {
        valueContainerByKey = .init()
        currentTimestamp = .init()
    }
    
    
}

extension ReplicatingDictionary: Replicable {
    
    
    func merged(with other: ReplicatingDictionary<Key, Value>) -> ReplicatingDictionary<Key, Value> {
        var resultDictionary = self
        resultDictionary.valueContainerByKey = other.valueContainerByKey.reduce(into: valueContainerByKey, { partialResult, entry in
            let firstValueContainer = partialResult[entry.key]
            let secondValueContainer = entry.value
            if let firstValueContainer = firstValueContainer {
                partialResult[entry.key] = firstValueContainer.lamportTimestamp > secondValueContainer.lamportTimestamp ? firstValueContainer : secondValueContainer
            } else {
                partialResult[entry.key] = secondValueContainer
            }
        })
        resultDictionary.currentTimestamp = max(currentTimestamp, other.currentTimestamp)
        return resultDictionary
    }
    
    
}


extension ReplicatingDictionary where Value: Replicable {
    
    func merged(with other: ReplicatingDictionary<Key, Value>) -> ReplicatingDictionary<Key, Value> {
        var haveTicked = false
        var resultDictionary = self
        resultDictionary.currentTimestamp = max(currentTimestamp, other.currentTimestamp)
        resultDictionary.valueContainerByKey = other.valueContainerByKey.reduce(into: valueContainerByKey, { partialResult, entry in
            let firstValueContainer = partialResult[entry.key]
            let secondValueContainer = entry.value
            if let firstValueContainer = firstValueContainer {
                if !firstValueContainer.isDeleted, !secondValueContainer.isDeleted {
                    if !haveTicked {
                        resultDictionary.currentTimestamp.tick()
                        haveTicked = true
                    }
                    let mergedValue = firstValueContainer.value.merged(with: secondValueContainer.value)
                    partialResult[entry.key] = ValueContainer(value: mergedValue, lamportTimestamp: resultDictionary.currentTimestamp)
                } else {
                    partialResult[entry.key] = firstValueContainer.lamportTimestamp > secondValueContainer.lamportTimestamp ? firstValueContainer : secondValueContainer
                }
            } else {
                partialResult[entry.key] = secondValueContainer
            }
        })
        return resultDictionary
    }
    
}
