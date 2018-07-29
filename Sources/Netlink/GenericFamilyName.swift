//
//  GenericFamilyName.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/7/18.
//

#if os(Linux)
import Glibc
#elseif os(macOS) || os(iOS)
import Darwin.C
#endif

import Foundation
import CLinuxWLAN

#if swift(>=3.2)
#elseif swift(>=3.0)
    import Codable
#endif

/// Netlink Generic Family Name
public struct NetlinkGenericFamilyName: RawRepresentable {
    
    public let rawValue: String
    
    public init(rawValue: String) {
        
        self.rawValue = rawValue
    }
}

// MARK: - Equatable

extension NetlinkGenericFamilyName: Equatable {
    
    public static func == (lhs: NetlinkGenericFamilyName, rhs: NetlinkGenericFamilyName) -> Bool {
        
        return lhs.rawValue == rhs.rawValue
    }
}

// MARK: - Codable

extension NetlinkGenericFamilyName: Codable {
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.singleValueContainer()
        
        let rawValue = try container.decode(String.self)
        
        self.init(rawValue: rawValue)
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.singleValueContainer()
        
        try container.encode(rawValue)
    }
}

// MARK: - Static Members

public extension NetlinkGenericFamilyName {
    
    public static let nl80211 = NetlinkGenericFamilyName(rawValue: NL80211_GENL_NAME)
}
