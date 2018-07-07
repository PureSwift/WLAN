//
//  Message.swift
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
import CNetlink
import CSwiftLinuxWLAN

/// Netlink message payload.
public final class NetlinkMessage {
    
    // MARK: - Properties
    
    @_versioned
    internal let managedPointer: ManagedPointer<UnmanagedPointer>
    
    // MARK: - Initialization
    
    internal init(_ managedPointer: ManagedPointer<UnmanagedPointer>) {
        
        self.managedPointer = managedPointer
    }
    
    /// Allocate a new netlink message with the default maximum payload size.
    public convenience init() {
        
        guard let rawPointer = nlmsg_alloc()
            else { fatalError("Could not initialize") }
        
        self.init(ManagedPointer(UnmanagedPointer(rawPointer)))
    }
    
    /// Allocate a new netlink message with maximum payload size specified.
    public convenience init(size: Int) {
        
        guard let rawPointer = nlmsg_alloc_size(size)
            else { fatalError("Could not initialize") }
        
        self.init(ManagedPointer(UnmanagedPointer(rawPointer)))
    }
    
    /// Allocate a new netlink message.
    ///
    /// - Parameter type: Netlink message type
    /// - Parameter flags: Netlink message flags.
    public convenience init(type: NetlinkMessageType, flags: NetlinkMessageFlag = 0) {
        
        guard let rawPointer = nlmsg_alloc_simple(Int32(type.rawValue), Int32(flags.rawValue))
            else { fatalError("Could not initialize") }
        
        self.init(ManagedPointer(UnmanagedPointer(rawPointer)))
    }
    
    // MARK: - Methods
    
    /// Calculates size of netlink message based on payload length.
    ///
    /// - Returns: Size of netlink message without padding.
    public static func size(for payloadLength: Int) -> Int {
        
        return Int(nlmsg_size(Int32(Int(payloadLength))))
    }
    
    /// Calculates size of netlink message including padding based on payload length.
    ///
    /// - Returns: Size of netlink message including padding.
    public static func totalSize(for payloadLength: Int) -> Int {
        
        return Int(nlmsg_total_size(Int32(Int(payloadLength))))
    }
    
    /// Size of padding that needs to be added at end of message.
    ///
    /// Calculates the number of bytes of padding which is required to be added
    /// to the end of the message to ensure that the next netlink message header
    /// begins properly aligned to `NLMSG_ALIGNTO`.
    ///
    /// - Parameter payload: Length of payload.
    ///
    /// - Returns: Number of bytes of padding needed.
    public static func padding(for payload: Int) -> Int {
        
        return Int(nlmsg_padlen(CInt(payload)))
    }
    
    /// Expand maximum payload size of a netlink message.
    ///
    /// Reallocates the payload section of a netlink message and increases the maximum payload size of the message.
    ///
    /// - Note: Any pointers pointing to old payload block will be stale and need to be refetched.
    /// Therfore, do not expand while constructing nested attributes or while reserved data blocks are held.
    public func expand(size: Int) throws {
        
        try nlmsg_expand(rawPointer, size).nlThrow()
    }
    
    /// Returns the actual netlink message casted to the type of the netlink message header.
    internal var dataPointer: UnsafeMutableRawPointer? {
        
        return withUnsafePointer { nlmsg_data($0) }
    }
    
    internal var dataLength: Int32 {
        
        return withUnsafePointer { nlmsg_datalen($0) }
    }
    
    public func withPayload <Result> (_ body: (Data) throws -> Result) rethrows -> Result {
        
        let data = Data(bytesNoCopy: dataPointer!,
                        count: Int(dataLength),
                        deallocator: Data.Deallocator.none)
        
        return try body(data)
    }
    
    /// Message payload.
    public var payload: Data {
        
        return withPayload { Data($0) }
    }
    
    /// Returns the actual netlink message casted to the type of the netlink message header.
    ///
    /// - Note: The pointer is only guarenteed to be valid for the lifetime of the closure.
    @inline(__always)
    internal func withUnsafePointer <Result> (_ body: (UnsafePointer<nlmsghdr>) throws -> Result) rethrows -> Result {
        
        // Return actual netlink message.
        guard let headerPointer = nlmsg_hdr(rawPointer)
            else { fatalError("Invalid pointer") }
        
        return try body(headerPointer)
    }
}

// MARK: - ManagedHandle

extension NetlinkMessage: ManagedHandle {
    
    typealias RawPointer = NetlinkMessage.UnmanagedPointer.RawPointer
}

// MARK: - UnmanagedPointer

extension NetlinkMessage {
    
    struct UnmanagedPointer: Netlink.UnmanagedPointer {
        
        let rawPointer: OpaquePointer
        
        @inline(__always)
        init(_ rawPointer: OpaquePointer) {
            self.rawPointer = rawPointer
        }
        
        @inline(__always)
        func retain() {
            nlmsg_get(rawPointer)
        }
        
        @inline(__always)
        func release() {
            nlmsg_free(rawPointer)
        }
    }
}

#endif
