//
//  NetworkInterface.swift
//  WLAN
//
//  Created by Alsey Coleman Miller on 7/5/18.
//
//

#if os(Linux)
    import Glibc
#elseif os(macOS) || os(iOS)
    import Darwin
#endif

import Foundation
import CSwiftLinuxWLAN

/// UNIX Network Interface
public struct NetworkInterface {
    
    public static func interfaces() throws -> [NetworkInterface] {
        
        var addressLinkedList: UnsafeMutablePointer<ifaddrs>? = nil
        
        guard getifaddrs(&addressLinkedList) == 0
            else { throw POSIXError.fromErrno! }
        
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
    
    public let name: String
    
    //public let address: sockaddr_ll
}
