//
//  GenericGroupIdentifier.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/28/18.
//

import Foundation
import CLinuxWLAN

/// Netlink Generic Family Group Identifier
public struct NetlinkGenericGroupIdentifier: RawRepresentable {
    
    public let rawValue: Int32
    
    public init(rawValue: Int32) {
        
        self.rawValue = rawValue
    }
}
