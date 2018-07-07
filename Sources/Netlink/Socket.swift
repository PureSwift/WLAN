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
    
    internal let rawPointer: OpaquePointer
    
    internal private(set) var callback: Callback?
    
    public init() {
        
        self.rawPointer = nl_socket_alloc()
    }
    
    deinit {
        
        nl_socket_free(rawPointer)
    }
    
    // MARK: - Methods
    
    /// Create file descriptor and bind socket.
    ///
    /// Creates a new Netlink socket using socket() and binds the socket to the protocol
    /// and local port specified in the sk socket object.
    ///
    /// Fails if the socket is already connected.
    public func connect(using socketProtocol: NetlinkSocketProtocol) throws {
        
        try nl_connect(rawPointer, socketProtocol.rawValue).nlThrow()
    }
    
    /// Transmit raw data over Netlink socket.
    public func send(_ data: Data) throws {
        
        let size = data.count
        
        try data.withUnsafeBytes {
            try nl_sendto(rawPointer, UnsafeMutableRawPointer(mutating: $0), size).nlThrow()
        }
    }
    
    /// Finalize and transmit Netlink message.
    @discardableResult
    public func send(message: NetlinkMessage) throws -> Int {
        
        let count = nl_send_auto(rawPointer, message.rawPointer)
        
        try count.nlThrow() // validate
        
        return Int(count)
    }
    
    /// Recieve answer.
    public func recieve() throws {
        
        try nl_recvmsgs_default(rawPointer).nlThrow()
    }
    
    public func modifyCallback(type: nl_cb_type, kind: nl_cb_kind, callback: @escaping Callback) throws {
        
        let objectPointer = Unmanaged.passUnretained(self).toOpaque()
        
        try nl_socket_modify_cb(rawPointer, type, kind, NetlinkSocketRecievedMessageCallback, objectPointer).nlThrow()
        
        self.callback = callback
    }
    
    // MARK: - Accessors
    
    /// Return the file descriptor of the backing socket.
    public var fileDescriptor: Int32? {
        
        // File descriptor or -1 if not available.
        let fileDescriptor = nl_socket_get_fd(rawPointer)
        
        return fileDescriptor != -1 ? fileDescriptor : nil
    }
}

// MARK: - Handle

extension NetlinkSocket: Handle { }

// MARK: - Callback

public extension NetlinkSocket {
    
    public typealias Callback = () -> (nl_cb_action)
}

@_silgen_name("swift_netlink_recvmsg_msg_cb")
fileprivate func NetlinkSocketRecievedMessageCallback(socket: OpaquePointer?, object: UnsafeMutableRawPointer?) -> Int32 {
    
    guard let object = object else { return 0 }
    
    let netlinkSocket = Unmanaged<NetlinkSocket>.fromOpaque(object).takeUnretainedValue()
    
    return Int32(netlinkSocket.callback?().rawValue ?? 0)
}


#endif
