//
//  Attribute.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/8/18.
//

import Foundation

/// Netlink Attribute Type
///
/// LTV (length, type, value) format.
///
/// - Note: As with every other integer in netlink sockets, the type and length values are also encoded with host endianness. Finally, netlink attributes must also be padded to a 4 byte boundary, just like netlink messages.
public struct NetlinkAttribute {
    
    /**
     Length (16 bits): the length of the entire attribute, including length, type, and value fields. May not be set to a 4 byte boundary. For example, if length is 17 bytes, the attribute will be padded to 20 bytes, but the 3 bytes of padding should not be interpreted as meaningful.
     */
    public var length: UInt16 {
        
        return UInt16(4 + payload.count)
    }
    
    /**
     Type (16 bits): the type of an attribute, typically defined as a constant in some netlink family or header.
     */
    public var type: NetlinkAttributeType
    
    /**
     Value (variable bytes): the raw payload of an attribute. May contain nested attributes, which are stored in the same format. Those nested attributes may contain even more nested attributes!
     */
    public var payload: Data
    
    public init(type: NetlinkAttributeType, payload: Data) {
        
        self.type = type
        self.payload = payload
    }
}

// MARK: - Common Attribute Types

public extension NetlinkAttribute {
    
    private init <T> (copying value: T, type: NetlinkAttributeType) {
        
        var value = value
        
        self.payload = withUnsafePointer(to: &value, { Data.init(bytes: $0, count: MemoryLayout<T>.size) })
        self.type = type
    }
    
    init(value: UInt8, type: NetlinkAttributeType) {
        
        self.init(copying: value, type: type)
    }
    
    init(value: UInt16, type: NetlinkAttributeType) {
        
        self.init(copying: value, type: type)
    }
    
    init(value: UInt32, type: NetlinkAttributeType) {
        
        self.init(copying: value, type: type)
    }
    
    init(value: UInt64, type: NetlinkAttributeType) {
        
        self.init(copying: value, type: type)
    }
}
