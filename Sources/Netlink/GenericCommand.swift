//
//  GenericCommand.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/7/18.
//

public struct NetlinkGenericCommand: RawRepresentable {
    
    public let rawValue: UInt8
    
    public init(rawValue: UInt8) {
        
        self.rawValue = rawValue
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension NetlinkGenericCommand: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt8) {
        
        self.init(rawValue: value)
    }
}
