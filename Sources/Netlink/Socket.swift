//
//  Socket.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/6/18.
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

public final class NetlinkSocket {
    
    internal let internalSocket: OpaquePointer
    
    public init() {
        
        self.internalSocket = nl_socket_alloc()
    }
    
    deinit {
        
        nl_socket_free(internalSocket)
    }
}

#endif
