//
//  GenericNetlink.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/7/18.
//

#if os(Linux)
import Glibc
#elseif os(macOS) || os(iOS)
import Darwin.C
#endif

#if os(Linux) || XcodeLinux

import Foundation
import CLinuxWLAN
import CNetlink

public final class NetlinkGenericSocket {
    
    // MARK: - Properties
    
    internal let internalReference: NetlinkSocket
    
    // MARK: - Initialization
    
    internal init(_ internalReference: NetlinkSocket) {
        
        self.internalReference = internalReference
    }
    
    // MARK: - Methods
    
    /// Resolve generic netlink family name to its identifier.
    ///
    /// - Parameter name: Name of generic netlink family.
    public func resolve(name: NetlinkGenericFamilyName) throws -> NetlinkGenericFamilyIdentifier {
        
        let identifier = genl_ctrl_resolve(rawPointer, name.rawValue)
        
        try identifier.nlThrow()
        
        return NetlinkGenericFamilyIdentifier(rawValue: identifier)
    }
    
    /// Resolve generic netlink group to its identifier.
    public func resolve(name: NetlinkGenericFamilyName,
                        group: NetlinkGenericGroup) throws -> Int32 {
        
        let identifier = genl_ctrl_resolve_grp(rawPointer, name.rawValue, group.rawValue)
        
        try identifier.nlThrow()
        
        return identifier
    }
}

// MARK: - Message Extension

public extension NetlinkSocket {
    
    public var genericView: NetlinkGenericSocket {
        
        return NetlinkGenericSocket(self)
    }
}

// MARK: - ManagedHandle

extension NetlinkGenericSocket: Handle {
    
    internal var rawPointer: NetlinkMessage.RawPointer { return internalReference.rawPointer }
}

#endif
