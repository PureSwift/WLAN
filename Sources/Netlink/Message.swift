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

public protocol NetlinkMessageProtocol {
    
    init?(data: Data)
    
    var data: Data { get }
    
    var payload: Data { get }
}

public enum NetlinkMessageDecodingError: Error {
    
    case invalidMessage(index: Int, data: Data)
}

public extension NetlinkMessageProtocol {
    
    public static func from(data: Data) throws -> [Self] {
        
        var messages = [Self]()
        
        var index = 0
        while index < data.count {
            
            let length = Int(UInt32(bytes: (data[index], data[index + 1], data[index + 2], data[index + 3])))
            
            let actualLength = length.extendTo4Bytes
            
            let messageData = Data(data[index ..< index + actualLength])
            
            guard let message = Self.init(data: messageData)
                else  { throw NetlinkMessageDecodingError.invalidMessage(index: index, data: messageData) }
            
            messages.append(message)
            
            index += actualLength
        }
        
        return messages
    }
}

/// Netlink message payload.
public struct NetlinkMessage: NetlinkMessageProtocol {
    
    internal static let minimumLength = NetlinkMessageHeader.length
    
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
    public var process: pid_t //UInt32
    
    /// Message payload.
    public var payload: Data
    
    // MARK: - Initialization
    
    public init(type: NetlinkMessageType,
                flags: NetlinkMessageFlag = 0,
                sequence: UInt32 = 0,
                process: pid_t = getpid(),
                payload: Data = Data()) {
        
        self.type = type
        self.flags = flags
        self.sequence = sequence
        self.process = process
        self.payload = payload
    }
}

public extension NetlinkMessage {
    
    public init?(data: Data) {
        
        guard let header = NetlinkMessageHeader(data: Data(data.prefix(NetlinkMessageHeader.length)))
            else { return nil }
        
        self.type = header.type
        self.flags = header.flags
        self.sequence = header.sequence
        self.process = header.process
        
        if data.count > NetlinkMessageHeader.length {
            
            let payloadLength = Int(header.length) - NetlinkMessageHeader.length
            
            self.payload = Data(data.suffix(from: NetlinkMessageHeader.length).prefix(payloadLength))
            
        } else {
            
            self.payload = Data()
        }
    }
    
    public var data: Data {
        
        return header.data + payload
    }
}

public extension NetlinkMessage {
    
    var header: NetlinkMessageHeader {
        
        return NetlinkMessageHeader(length: length,
                                    type: type,
                                    flags: flags,
                                    sequence: sequence,
                                    process: process)
    }
}
