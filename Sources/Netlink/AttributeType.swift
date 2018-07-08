//
//  NetlinkAttribute.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/7/18.
//

/// Netlink Attribute Type
public struct NetlinkAttributeType: RawRepresentable {
    
    public let rawValue: UInt16
    
    public init(rawValue: UInt16) {
        
        self.rawValue = rawValue
    }
}
