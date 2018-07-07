//
//  Error.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/6/18.
//

/// Netlink Error
public struct NetlinkError: Error, RawRepresentable {
    
    public let rawValue: Int32
    
    public init(rawValue: Int32) {
        
        self.rawValue = rawValue
    }
}

internal extension CInt {
    
    @inline(__always)
    func nlThrow() throws {
        
        guard self == 0 else { throw NetlinkError(rawValue: self) }
    }
}
