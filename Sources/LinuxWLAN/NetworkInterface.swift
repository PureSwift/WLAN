//
//  NetworkInterface.swift
//  WLAN
//
//  Created by Alsey Coleman Miller on 7/5/18.
//
//

#if os(Linux)
import Glibc
#elseif canImport(Darwin)
import Darwin
#endif

import SystemPackage

/// UNIX Network Interface
internal struct NetworkInterface: Equatable, Hashable {
    
    /// Interface name.
    public let name: String
}

internal extension NetworkInterface {
    
    static func interfaces() throws -> [NetworkInterface] {
        
        var addressLinkedList: UnsafeMutablePointer<ifaddrs>? = nil
        
        guard getifaddrs(&addressLinkedList) == 0
            else { throw Errno(rawValue: errno) }
        
        var interfaces = [NetworkInterface]()
        var nextElement = addressLinkedList
        while let interface = nextElement?.pointee {
            nextElement = interface.ifa_next
            guard interface.ifa_addr?.pointee.sa_family == sa_family_t(AF_PACKET)
                else { continue }
            let name = String(cString: interface.ifa_name)
            interfaces.append(NetworkInterface(name: name))
        }
        
        return interfaces
    }
    
    /// Returns the index of the network interface corresponding to the name
    static func index(for interface: NetworkInterface) throws -> UInt32 {
        let index = if_nametoindex(interface.name)
        guard index != 0 else { throw Errno(rawValue: errno) }
        return index
    }
}

#if !os(Linux)
var AF_PACKET: CInt { fatalError("AF_PACKET is Linux-only") }
#endif
