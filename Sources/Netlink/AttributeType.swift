//
//  NetlinkAttribute.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/7/18.
//

import CLinuxWLAN

/// Netlink Attribute Type
public struct NetlinkAttributeType: RawRepresentable, OptionSet {
    
    public let rawValue: UInt16
    
    public init(rawValue: UInt16) {
        
        self.rawValue = rawValue
    }
}

// MARK: - Equatable

extension NetlinkAttributeType: Equatable {
    
    public static func == (lhs: NetlinkAttributeType, rhs: NetlinkAttributeType) -> Bool {
        
        return lhs.rawValue == rhs.rawValue
    }
}

// MARK: - Hashable

extension NetlinkAttributeType: Hashable {
    
    public var hashValue: Int {
        
        return rawValue.hashValue
    }
}

// MARK: - Static Types

public extension NetlinkAttributeType {
    
    public static let nested = NetlinkAttributeType(rawValue: UInt16(NLA_F_NESTED))
    
    public static let networkByteOrder = NetlinkAttributeType(rawValue: UInt16(NLA_F_NET_BYTEORDER))
    
    public enum Generic {
        
        public static let familyIdentifier = NetlinkAttributeType(rawValue: UInt16(CTRL_ATTR_FAMILY_ID))
        
        public static let familyName = NetlinkAttributeType(rawValue: UInt16(CTRL_ATTR_FAMILY_NAME))
        
        public static let version = NetlinkAttributeType(rawValue: UInt16(CTRL_ATTR_VERSION))
        
        public static let headerSize = NetlinkAttributeType(rawValue: UInt16(CTRL_ATTR_HDRSIZE))
        
        public static let maxAttributes = NetlinkAttributeType(rawValue: UInt16(CTRL_ATTR_MAXATTR))
        
        public static let operations = NetlinkAttributeType(rawValue: UInt16(CTRL_ATTR_OPS))
        
        public static let multicastGroups = NetlinkAttributeType(rawValue: UInt16(CTRL_ATTR_MCAST_GROUPS))
    }
}
