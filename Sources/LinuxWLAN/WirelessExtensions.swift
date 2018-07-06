//
//  WirelessExtensions.swift
//  LinuxWLAN
//
//  Created by Alsey Coleman Miller on 7/5/18.
//

#if os(Linux)
import Glibc
#elseif os(macOS) || os(iOS)
import Darwin.C
#endif

import Foundation
import WLAN
import CSwiftLinuxWLAN

public extension LinuxWLANManager {
    
    func wirelessExtensionName(for interface: WLANInterface) throws -> String {
        
        typealias Name = (Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8)
        
        var request = iwreq()
        request.setInterfaceName(interface.name)
        
        guard IOControl(internalSocket, SIOCGIWNAME, &request) != -1
            else { throw POSIXError.fromErrno! }
        
        var nameBuffer = UnsafeMutablePointer<Name>.allocate(capacity: 1)
        
        nameBuffer.pointee = request.u.name
        
        defer { nameBuffer.deallocate(capacity: 1) }
        
        return nameBuffer.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Name>.size, { String(cString: $0) })
    }
    
    func wirelessExtensionVersion(for interface: WLANInterface) throws -> UInt8 {
        
        var result = [iw_range](repeating: iw_range(), count: 2)
        try result.withUnsafeMutableBytes {
            
            var request = iwreq()
            request.setInterfaceName(interface.name)
            
            request.u.data.pointer = UnsafeMutableRawPointer($0.baseAddress!)
            request.u.data.length = __u16(MemoryLayout<iw_range>.size * 2)
            request.u.data.flags = 0
            
            guard IOControl(internalSocket, SIOCGIWNAME, &request) != -1
                else { throw POSIXError.fromErrno! }
        }
        
        return result[0].we_version_compiled
    }
}
