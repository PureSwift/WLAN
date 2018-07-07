//
//  SocketProtocol.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/6/18.
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

/// Netlink Socket Protocol
public struct NetlinkSocketProtocol: RawRepresentable {
    
    public let rawValue: Int32
    
    public init(rawValue: Int32) {
        
        self.rawValue = rawValue
    }
}

public extension NetlinkSocketProtocol {
    
    /// Netlink Generic Protocol
    public static let generic = NetlinkSocketProtocol(rawValue: NETLINK_GENERIC)
    
    /// Netlink Routing Protocol
    public static let route = NetlinkSocketProtocol(rawValue: NETLINK_ROUTE)
}

#endif
