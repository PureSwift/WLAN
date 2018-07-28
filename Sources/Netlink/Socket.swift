//
//  Socket.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/6/18.
//

#if os(Linux)
import Glibc
#elseif os(macOS)
import Darwin.C
#endif

import Foundation
import CLinuxWLAN

public final class NetlinkSocket {
    
    // MARK: - Properties
    
    internal let internalSocket: CInt
    
    // MARK: - Initialization
    
    deinit {
        
        close(internalSocket)
    }
    
    public init(_ netlinkProtocol: NetlinkSocketProtocol, group: Int32 = 0) throws {
        
        // open socket
        let fileDescriptor = socket(PF_NETLINK, SOCK_RAW, netlinkProtocol.rawValue)
        
        guard fileDescriptor >= 0
            else { throw POSIXError.fromErrno! }
        
        var address = sockaddr_nl(nl_family: __kernel_sa_family_t(AF_NETLINK),
                                  nl_pad: UInt16(),
                                  nl_pid: __u32(getpid()),
                                  nl_groups: __u32(bitPattern: group))
        
        // initialize socket
        self.internalSocket = fileDescriptor
        
        // bind socket
        guard withUnsafePointer(to: &address, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1, {
                bind(internalSocket, $0, socklen_t(MemoryLayout<sockaddr_nl>.size))
            })
        }) >= 0 else { throw POSIXError.fromErrno! }
    }
    
    // MARK: - Methods
    
    @discardableResult
    public func send(_ data: Data) throws -> Int {
        
        var address = sockaddr_nl(nl_family: __kernel_sa_family_t(AF_NETLINK),
                                  nl_pad: 0,
                                  nl_pid: 0,
                                  nl_groups: 0)
        
        let sentBytes = withUnsafePointer(to: &address, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1, { (socketPointer) in
                data.withUnsafeBytes { (dataPointer: UnsafePointer<UInt8>) in
                    sendto(internalSocket, UnsafeRawPointer(dataPointer), data.count, 0, socketPointer, socklen_t(MemoryLayout<sockaddr_nl>.size))
                }
            })
        })
        
        guard sentBytes >= 0
            else { throw POSIXError.fromErrno! }
        
        return sentBytes
    }
}

internal let AF_NETLINK: CInt = 16

internal let PF_NETLINK: CInt = 16
