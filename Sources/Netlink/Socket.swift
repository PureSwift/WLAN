//
//  Socket.swift
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
import CSwiftLinuxWLAN

public final class NetlinkSocket {
    
    internal let internalSocket: CInt
    
    public init() throws {
        
        
    }
}
