//
//  NetlinkAttribute.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/7/18.
//

/// Netlink Attribute Type
public struct NetlinkAttribute: RawRepresentable {
    
    public let rawValue: Int32
    
    public init(rawValue: Int32) {
        
        self.rawValue = rawValue
    }
}
