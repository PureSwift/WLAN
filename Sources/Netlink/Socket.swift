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
    
    // MARK: - Methods
    
    /// Create file descriptor and bind socket.
    ///
    /// Creates a new Netlink socket using socket() and binds the socket to the protocol
    /// and local port specified in the sk socket object.
    ///
    /// Fails if the socket is already connected.
    public func connect(using socketProtocol: NetlinkSocketProtocol) throws {
        
        try nl_connect(internalSocket, socketProtocol.rawValue).nlThrow()
    }
    
    /// Transmit raw data over Netlink socket.
    public func send(_ data: Data) throws {
        
        let size = data.count
        
        try data.withUnsafeBytes {
            try nl_sendto(internalSocket, UnsafeMutableRawPointer(mutating: $0), size).nlThrow()
        }
    }
}

#endif
