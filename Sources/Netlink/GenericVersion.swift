//
//  GenericVersion.swift
//  WLAN
//
//  Created by Alsey Coleman Miller on 7/27/18.
//
//

public struct NetlinkGenericVersion: RawRepresentable {
    
    public let rawValue: UInt8
    
    public init(rawValue: UInt8) {
        
        self.rawValue = rawValue
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension NetlinkGenericVersion: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt8) {
        
        self.init(rawValue: value)
    }
}
