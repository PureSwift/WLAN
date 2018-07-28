//
//  NetlinkAttribute.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/7/18.
//

import CLinuxWLAN

/// Netlink Attribute Type
public struct NetlinkAttributeType: RawRepresentable {
    
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
    
    public enum Generic {
        
        public static let familyName = NetlinkAttributeType(rawValue: UInt16(CTRL_ATTR_FAMILY_NAME))
        
        public static let familyIdentifier = NetlinkAttributeType(rawValue: UInt16(CTRL_ATTR_FAMILY_ID))
    }
}
