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
    
    internal static let headerLength = 4
    
    /**
     Length (16 bits): the length of the entire attribute, including length, type, and value fields. May not be set to a 4 byte boundary. For example, if length is 17 bytes, the attribute will be padded to 20 bytes, but the 3 bytes of padding should not be interpreted as meaningful.
     */
    public var length: UInt16 {
        
        return UInt16(NetlinkAttribute.headerLength + payload.count)
    }
    
    public var paddedLength: Int {
        
        return Int(length).extendTo4Bytes
    }
    
    /**
     Type (16 bits): the type of an attribute, typically defined as a constant in some netlink family or header.
     */
    public var type: NetlinkAttributeType
    
    /**
     Value (variable bytes): the raw payload of an attribute. May contain nested attributes, which are stored in the same format. Those nested attributes may contain even more nested attributes!
     */
    public var payload: Data
    
    public init(type: NetlinkAttributeType,
                payload: Data) {
        
        self.type = type
        self.payload = payload
    }
}

public extension NetlinkAttribute {
    
    public init?(data: Data) {
        
        guard data.count >= NetlinkAttribute.headerLength
            else { return nil }
        
        let length = UInt16(bytes: (data[0], data[1]))
        self.type = NetlinkAttributeType(rawValue: UInt16(bytes: (data[2], data[3])))
        
        if data.count > NetlinkAttribute.headerLength {
            
            self.payload = Data(data[NetlinkAttribute.headerLength ..< Int(length)])
            
        } else {
            
            self.payload = Data()
        }
    }
    
    public var data: Data {
        
        return Data([
            length.bytes.0,
            length.bytes.1,
            type.rawValue.bytes.0,
            type.rawValue.bytes.1
            ]) + payload
    }
    
    public var paddedData: Data {
        
        let padding = paddedLength - Int(length)
        
        return data + Data(count: padding)
    }
}

// MARK: - Common Attribute Types

public extension NetlinkAttribute {
    
    private init <T> (copying value: T, type: NetlinkAttributeType) {
        
        var value = value
        
        self.payload = withUnsafePointer(to: &value, { Data(bytes: $0, count: MemoryLayout<T>.size) })
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
    
    init(value: Int8, type: NetlinkAttributeType) {
        
        self.init(copying: value, type: type)
    }
    
    init(value: Int16, type: NetlinkAttributeType) {
        
        self.init(copying: value, type: type)
    }
    
    init(value: Int32, type: NetlinkAttributeType) {
        
        self.init(copying: value, type: type)
    }
    
    init(value: Int64, type: NetlinkAttributeType) {
        
        self.init(copying: value, type: type)
    }
}

public extension NetlinkAttribute {
    
    init(value: Bool, type: NetlinkAttributeType) {
        
        self.init(value: UInt8(value ? 1 : 0), type: type)
    }
    
    init(value: String, type: NetlinkAttributeType) {
        
        self.payload = Data(unsafeBitCast(value.utf8CString, to: ContiguousArray<UInt8>.self))
        self.type = type
    }
}
