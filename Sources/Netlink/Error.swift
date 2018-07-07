//
//  Error.swift
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

/// Netlink Error
public struct NetlinkError: Error, RawRepresentable {
    
    public let rawValue: Int32
    
    public init(rawValue: Int32) {
        
        self.rawValue = rawValue
    }
}

// MARK: - Equatable

extension NetlinkError: Equatable {
    
    public static func == (lhs: NetlinkError, rhs: NetlinkError) -> Bool {
        
        return lhs.rawValue == rhs.rawValue
    }
}

// MARK: - Hashable

extension NetlinkError: Hashable {
    
    public var hashValue: Int {
        
        return rawValue.hashValue
    }
}

// MARK: - CustomStringConvertible

extension NetlinkError: CustomStringConvertible {
    
    public var description: String {
        
        return String(cString: nl_geterror(rawValue))
    }
}

// MARK: - POSIX Error

public extension NetlinkError {
    
    public init(_ error: POSIXError) {
        
        self.init(rawValue: nl_syserr2nlerr(error.code.rawValue))
    }
}

// MARK: - Utilities

internal extension CInt {
    
    @inline(__always)
    func nlThrow() throws {
        
        guard self >= 0 else { throw NetlinkError(rawValue: -self) }
    }
}

// MARK: - Definitions

public extension NetlinkError {
    
    public static let failure = NetlinkError(rawValue: NLE_FAILURE)
}

#endif
