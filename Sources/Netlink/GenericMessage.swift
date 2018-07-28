//
//  GenericMessage.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/7/18.
//

#if os(Linux)
import Glibc
#elseif os(macOS) || os(iOS)
import Darwin.C
#endif

import Foundation
import CLinuxWLAN

/// Netlink generic message payload.
public struct NetlinkGenericMessage: NetlinkMessageProtocol {
    
    internal static let headerLength = NetlinkMessageHeader.length + 4
    
    // MARK: - Properties
    
    /**
     Length: 32 bits
     
     The length of the message in bytes, including the header.
     */
    public var length: UInt32 {
        
        return UInt32(NetlinkGenericMessage.headerLength + payload.count)
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
    public var process: pid_t
    
    public var command: NetlinkGenericCommand
    
    public var version: NetlinkGenericVersion
    
    internal var unused: UInt16 = 0 // padding
    
    /// Message payload.
    public var payload: Data
    
    // MARK: - Initialization
    
    public init(type: NetlinkMessageType = NetlinkMessageType(),
                flags: NetlinkMessageFlag = 0,
                sequence: UInt32 = 0,
                process: pid_t = getpid(),
                command: NetlinkGenericCommand = 0,
                version: NetlinkGenericVersion = 0,
                payload: Data = Data()) {
        
        self.type = type
        self.flags = flags
        self.sequence = sequence
        self.process = process
        self.command = command
        self.version = version
        self.payload = payload
    }
}

public extension NetlinkGenericMessage {
    
    public init?(data: Data) {
        
        let headerLength = type(of: self).headerLength
        
        guard data.count >= headerLength
            else { return nil }
        
        let length = UInt32(bytes: (data[0], data[1], data[2], data[3]))
        
        // netlink header
        self.type = NetlinkMessageType(rawValue: UInt16(bytes: (data[4], data[5])))
        self.flags = NetlinkMessageFlag(rawValue: UInt16(bytes: (data[6], data[7])))
        self.sequence = UInt32(bytes: (data[8], data[9], data[10], data[11]))
        self.process = pid_t(bytes: (data[12], data[13], data[14], data[15]))
        
        // generic header
        self.command = NetlinkGenericCommand(rawValue: data[16])
        self.version = NetlinkGenericVersion(rawValue: data[17])
        self.unused = UInt16(bytes: (data[18], data[19]))
        
        // payload 
        if data.count > type(of: self).headerLength {
            
            let payloadLength = Int(length) - headerLength
            
            self.payload = Data(data.suffix(from: headerLength).prefix(payloadLength))
            
        } else {
            
            self.payload = Data()
        }
    }
    
    public var data: Data {
        
        return Data([
            length.bytes.0,
            length.bytes.1,
            length.bytes.2,
            length.bytes.3,
            type.rawValue.bytes.0,
            type.rawValue.bytes.1,
            flags.rawValue.bytes.0,
            flags.rawValue.bytes.1,
            sequence.bytes.0,
            sequence.bytes.1,
            sequence.bytes.2,
            sequence.bytes.3,
            process.bytes.0,
            process.bytes.1,
            process.bytes.2,
            process.bytes.3,
            command.rawValue,
            version.rawValue,
            unused.bytes.0,
            unused.bytes.1
            ]) + payload
    }
}
