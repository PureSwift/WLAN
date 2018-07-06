//
//  MessageType.swift
//  WLAN
//
//  Created by Alsey Coleman Miller on 7/6/18.
//
//

#if os(Linux)
    import Glibc
#elseif os(macOS) || os(iOS)
    import Darwin.C
#endif

import Foundation
import CSwiftLinuxWLAN

/// Netlink Message Type
public struct NetlinkMessageType: RawRepresentable {
    
    public let rawValue: UInt16
    
    public init(rawValue: UInt16) {
        
        self.rawValue = rawValue
    }
}

public extension NetlinkMessageType {
    
    /// Message is ignored.
    public static let ignored = NetlinkMessageType(rawValue: UInt16(NLMSG_NOOP))
    
    /// The message signals an error and the payload
    /// contains a nlmsgerr structure.  This can be looked
    /// at as a NACK and typically it is from FEC to CPC.
    public static let error = NetlinkMessageType(rawValue: UInt16(NLMSG_ERROR))
    
    /// Message terminates a multipart message.
    public static let done = NetlinkMessageType(rawValue: UInt16(NLMSG_DONE))
}
