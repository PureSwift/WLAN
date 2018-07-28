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
    
    public let rawValue: Int32
    
    public init(rawValue: Int32) {
        
        self.rawValue = rawValue
    }
}

// MARK: - Static Identifiers

public extension NetlinkGenericFamilyIdentifier {
    
    public static let generate = NetlinkGenericFamilyIdentifier(rawValue: GENL_ID_GENERATE)
    
    public static let control = NetlinkGenericFamilyIdentifier(rawValue: GENL_ID_CTRL)
}
