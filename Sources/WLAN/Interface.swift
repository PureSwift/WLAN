//
//  WLAN.swift
//  PureSwift
//
//  Created by Alsey Coleman Miller on 7/3/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

/// Encapsulates an IEEE 802.11 interface.
public struct WLANInterface {
    
    /// The BSD name of the interface.
    public let name: String
    
    public init(name: String) {
        
        self.name = name
    }
}

// MARK: - Equatable

extension WLANInterface: Equatable {
    
    public static func == (rhs: WLANInterface, lhs: WLANInterface) -> Bool {
        
        return rhs.name == lhs.name
    }
}

// MARK: - Hashable

extension WLANInterface: Hashable {
    
    public var hashValue: Int {
        
        return name.hashValue
    }
}

// MARK: - CustomStringConvertible

extension WLANInterface: CustomStringConvertible {
    
    public var description: String {
        
        return name
    }
}
