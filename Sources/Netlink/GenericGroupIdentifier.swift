//
//  GenericGroupIdentifier.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/28/18.
//

import Foundation
import CLinuxWLAN

#if swift(>=3.2)
#elseif swift(>=3.0)
    import Codable
#endif

/// Netlink Generic Family Group Identifier
public struct NetlinkGenericGroupIdentifier: RawRepresentable {
    
    public let rawValue: Int32
    
    public init(rawValue: Int32) {
        
        self.rawValue = rawValue
    }
}

// MARK: - Equatable

extension NetlinkGenericGroupIdentifier: Equatable {
    
    public static func == (lhs: NetlinkGenericGroupIdentifier, rhs: NetlinkGenericGroupIdentifier) -> Bool {
        
        return lhs.rawValue == rhs.rawValue
    }
}

// MARK: - Codable

extension NetlinkGenericGroupIdentifier: Codable {
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.singleValueContainer()
        
        let rawValue = try container.decode(Int32.self)
        
        self.init(rawValue: rawValue)
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.singleValueContainer()
        
        try container.encode(rawValue)
    }
}
