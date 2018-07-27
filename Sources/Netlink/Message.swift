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

import Foundation
import CLinuxWLAN

/// Netlink message payload.
public struct NetlinkMessage {
    
    // MARK: - Properties
    
    /**
     Length: 32 bits
     
     The length of the message in bytes, including the header.
     */
    public var length: UInt32 {
        
        return UInt32(NetlinkMessageHeader.length + payload.count)
    }
    
    /**
     Type: 16 bits
     
     This field describes the message content.
     It can be one of the standard message types:
     * NLMSG_NOOP  Message is ignored.
     * NLMSG_ERROR The message signals an error and the payload
     contains a nlmsgerr structure.  This can be looked
     at as a NACK and typically it is from FEC to CPC.
     * NLMSG_DONE  Message terminates a multipart message.
     */
    
    public var type: NetlinkMessageType
    
    /**
     Flags: 16 bits
     */
    public var flags: NetlinkMessageFlag
    
    /**
     Sequence Number: 32 bits
     
     The sequence number of the message.
     */
    public var sequence: UInt32
    
    /**
     Process ID (PID): 32 bits
     
     The PID of the process sending the message. The PID is used by the
     kernel to multiplex to the correct sockets. A PID of zero is used
     when sending messages to user space from the kernel.
     */
    public var processID: pid_t //UInt32
    
    /// Message payload.
    public var payload: Data
    
    // MARK: - Initialization
    
    public init(type: NetlinkMessageType,
                flags: NetlinkMessageFlag = 0,
                sequence: UInt32 = 0,
                processID: pid_t = getpid(),
                payload: Data = Data()) {
        
        self.type = type
        self.flags = flags
        self.sequence = sequence
        self.processID = processID
        self.payload = payload
    }
    
    // MARK: - Methods
    
    // MARK: - Attributes
    
    /// Add 32 bit integer attribute to netlink message.
    ///
    /// - Parameter value: Numeric value to store as payload.
    /// - Parameter attribute: Attribute type.
    public func setValue(_ value: UInt32, for attribute: NetlinkAttribute) throws {
        
        
    }
}
