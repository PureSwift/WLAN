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

#if os(Linux) || Xcode

import Foundation
import CNetlink
import CSwiftLinuxWLAN

/// Netlink generic message payload.
public final class NetlinkGenericMessage {
    
    // MARK: - Properties
    
    internal let internalReference: NetlinkMessage
    
    // MARK: - Initialization
    
    internal init(_ internalReference: NetlinkMessage) {
        
        self.internalReference = internalReference
    }
    
    // MARK: - Methods
    
    /// Add Generic Netlink headers to Netlink message.
    @discardableResult
    public func put(port: UInt32,
                    sequence: UInt32,
                    family: NetlinkGenericFamilyIdentifier,
                    headerLength: Int32,
                    flags: NetlinkMessageFlag = 0,
                    command: NetlinkGenericCommand,
                    version: UInt8) -> Bool {
        
        /// Returns Pointer to user header or NULL if an error occurred.
        guard let _ = genlmsg_put(rawPointer,
                                        port,
                                        sequence,
                                        family.rawValue,
                                        headerLength,
                                        Int32(flags.rawValue),
                                        command.rawValue,
                                        version)
            else { return false }
        
        return true
    }
}

// MARK: - Message Extension

public extension NetlinkMessage {
    
    public var genericView: NetlinkGenericMessage {
        
        return NetlinkGenericMessage(self)
    }
}

// MARK: - ManagedHandle

extension NetlinkGenericMessage: Handle {
    
    internal var rawPointer: NetlinkMessage.RawPointer { return internalReference.rawPointer }
}

#endif
