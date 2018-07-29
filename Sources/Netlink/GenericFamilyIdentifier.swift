//
//  NetlinkGenericFamilyIdentifier.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/7/18.
//

import Foundation
import CLinuxWLAN

/// Netlink Generic Family Identifier
public struct NetlinkGenericFamilyIdentifier: RawRepresentable {
    
    public let rawValue: UInt16
    
    public init(rawValue: UInt16) {
        
        self.rawValue = rawValue
    }
}

// MARK: - Static Identifiers

public extension NetlinkGenericFamilyIdentifier {
    
    public static let generate = NetlinkGenericFamilyIdentifier(rawValue: UInt16(GENL_ID_GENERATE))
    
    public static let controller = NetlinkGenericFamilyIdentifier(rawValue: UInt16(GENL_ID_CTRL))
}

// MARK: - Codable

extension NetlinkGenericFamilyIdentifier: Codable {
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.singleValueContainer()
        
        let rawValue = try container.decode(UInt16.self)
        
        self.init(rawValue: rawValue)
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.singleValueContainer()
        
        try container.encode(rawValue)
    }
}
