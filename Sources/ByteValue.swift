//
//  ByteValueType.swift
//  WLAN
//
//  Created by Alsey Coleman Miller on 7/4/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

/// Stores a primitive value. 
///
/// Useful for Swift wrappers for primitive byte types. 
public protocol ByteValue: Equatable {
    
    associatedtype ByteValue
    
    /// Returns the the primitive byte type.
    var bytes: ByteValue { get }
    
    /// Initializes with the primitive the primitive byte type.
    init(bytes: ByteValue)
}
