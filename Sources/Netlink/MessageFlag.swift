//
//  MessageFlag.swift
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

/// Netlink Message Flag
public struct NetlinkMessageFlag: RawRepresentable {
    
    public let rawValue: UInt16
    
    public init(rawValue: UInt16 = 0) {
        
        self.rawValue = rawValue
    }
}

// MARK: - Constants

// The standard flag bits used in Netlink
public extension NetlinkMessageFlag {
    
    /// Must be set on all request messages (typically from user space to kernel space).
    public static let request = NetlinkMessageFlag(rawValue: UInt16(NLM_F_REQUEST))
    
    /// Indicates the message is part of a multipart message terminated by `.done`.
    public static let mulitpart = NetlinkMessageFlag(rawValue: UInt16(NLM_F_MULTI))
    
    /// Request for an acknowledgment on success.
    /// Typical direction of request is from user
    public static let acknowledgment = NetlinkMessageFlag(rawValue: UInt16(NLM_F_ACK))
    
    /// Echo this request.
    /// Typical direction of request is from user space (CPC) to kernel space (FEC).
    public static let echo = NetlinkMessageFlag(rawValue: UInt16(NLM_F_ECHO))
}

public extension NetlinkMessageFlag {
    
    /// Additional flag bits for GET requests on config information in the FEC.
    public enum Get {
        
        /// Return the complete table instead of a single entry.
        public static let root = NetlinkMessageFlag(rawValue: UInt16(NLM_F_ROOT))
        
        /// Return all entries matching criteria passed in message content.
        public static let match = NetlinkMessageFlag(rawValue: UInt16(NLM_F_MATCH))
        
        /// Return an atomic snapshot of the table being referenced. 
        /// This may require special privileges because it has the potential 
        /// to interrupt service in the FE for a longer time.
        public static let atomic = NetlinkMessageFlag(rawValue: UInt16(NLM_F_ATOMIC))
        
        /// This is `NLM_F_ROOT` or'ed with `NLM_F_MATCH`.
        public static let dump: NetlinkMessageFlag = [root, atomic]
    }
}

public extension NetlinkMessageFlag {
    
    /// Additional flag bits for NEW requests.
    public enum New {
        
        /// Replace existing matching config object with this request.
        public static let replace = NetlinkMessageFlag(rawValue: UInt16(NLM_F_REPLACE))
        
        /// Don't replace the config object if it already exists.
        public static let exclude = NetlinkMessageFlag(rawValue: UInt16(NLM_F_EXCL))
        
        /// Create config object if it doesn't already exist.
        public static let create = NetlinkMessageFlag(rawValue: UInt16(NLM_F_CREATE))
        
        /// Add to the end of the object list.
        public static let append = NetlinkMessageFlag(rawValue: UInt16(NLM_F_APPEND))
    }
}

// MARK: - BitMaskOption

extension NetlinkMessageFlag: OptionSet { }

// MARK: - Equatable

extension NetlinkMessageFlag: Equatable {
    
    public static func == (lhs: NetlinkMessageFlag, rhs: NetlinkMessageFlag) -> Bool {
        
        return lhs.rawValue == rhs.rawValue
    }
}

// MARK: - Hashable

extension NetlinkMessageFlag: Hashable {
    
    public var hashValue: Int {
        
        return rawValue.hashValue
    }
}
