//
//  Replicable.swift
//  
//
//  Created by Amit Samant on 2/6/24.
//

import Foundation

public protocol Replicable {
    func merged(with other: Self) -> Self
}
