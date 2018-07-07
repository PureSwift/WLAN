//
//  GenericNetlink.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/7/18.
//

#if os(Linux)
import Glibc
#elseif os(macOS) || os(iOS)
import Darwin.C
#endif

#if os(Linux) || Xcode

import Foundation
import CSwiftLinuxWLAN
import CNetlink

public final class NetlinkGenericSocket {
    
    // MARK: - Properties
    
    internal let socket: NetlinkSocket
    
    internal var rawPointer: OpaquePointer { return socket.rawPointer }
    
    // MARK: - Initialization
    
    public init() throws {
        
        self.socket = NetlinkSocket()
        
        try socket.connect(using: .generic)
    }
    
    // MARK: - Methods
    
    /// Resolve generic netlink family name to its identifier.
    ///
    /// - Parameter name: Name of generic netlink family
    public func resolve(name: String) throws {
        
        try genl_ctrl_resolve(rawPointer, name).nlThrow()
    }
}

extension NetlinkGenericSocket: Handle { }

#endif
