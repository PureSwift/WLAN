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

#if os(Linux) || XcodeLinux

import Foundation
import CNetlink
import CLinuxWLAN

/// Netlink Generic Family Name
public struct NetlinkGenericFamilyName: RawRepresentable {
    
    public let rawValue: String
    
    public init(rawValue: String) {
        
        self.rawValue = rawValue
    }
}

public extension NetlinkGenericFamilyName {
    
    public static let nl80211 = NetlinkGenericFamilyName(rawValue: NL80211_GENL_NAME)
}

#endif
