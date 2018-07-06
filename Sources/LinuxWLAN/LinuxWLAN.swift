//
//  WLANProtocol.swift
//  WLAN
//
//  Created by Alsey Coleman Miller on 7/4/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

#if os(Linux)
    import Glibc
#elseif os(macOS) || os(iOS)
    import Darwin.C
#endif

import Foundation
import WLAN
import CSwiftLinuxWLAN

/**
 Linux WLAN Manager
 
 A wrapper around the entire Wi-Fi subsystem that you use to access interfaces.
 */
public final class LinuxWLANManager: WLANManager {
    
    // MARK: - Properties
    
    /// Socket handle to kernel network interfaces subsystem.
    internal let internalSocket: CInt
    
    // MARK: - Initialization
    
    public init() throws {
        
        let netSocket = socket(AF_INET, SOCK_STREAM, 0)
        
        guard netSocket >= 0 else { throw POSIXError.fromErrno! }
        
        self.internalSocket = netSocket
    }
    
    deinit {
        
        close(internalSocket)
    }
    
    // MARK: - Methods
    
    /// Returns the default Wi-Fi interface.
    public var interface: WLANInterface? { return interfaces.first }
    
    /**
     Returns all available Wi-Fi interfaces.
     
     - Returns: An array of `WLANInterface`, representing all of the available Wi-Fi interfaces in the system.
     */
    public var interfaces: [WLANInterface] {
        
        return try! wirelessInterfaces()
    }
    
    /**
     Scans for networks.
     
     If ssid parameter is present, a directed scan will be performed by the interface, otherwise a broadcast scan will be performed. This method will block for the duration of the scan.
     
     - Parameter ssid: The SSID for which to scan.
     - Parameter interface: The network interface.
     */
    public func scan(with ssid: SSID? = nil, for interface: WLANInterface) throws -> [WLANNetwork] { return [] }
    
    /**
     Sets the interface power state.
     
     - Parameter power: A Boolean value corresponding to the power state. NO indicates the "OFF" state.
     - Parameter interface: The network interface.
     */
    public func setPower(_ power: Bool, for interface: WLANInterface) throws {  }
    
    /**
     Disassociates from the current network.
     
     This method has no effect if the interface is not associated to a network.
     */
    public func disassociate(interface: WLANInterface) throws { }
}

// MARK: - Linux Extensions

public extension LinuxWLANManager {
    
    internal func wirelessInterfaces() throws -> [WLANInterface] {
        
        let networkInterfaces = try NetworkInterface.interfaces()
        
        var wlanInterfaces = [WLANInterface]()
        
        for interface in networkInterfaces {
            
            do { let _ = try wirelessExtensionName(for: interface.name) }
            catch { continue }
            
            wlanInterfaces.append(WLANInterface(name: interface.name))
        }
        
        return wlanInterfaces
    }
    
    internal func wirelessExtensionName(for interface: String) throws -> String {
        
        var request = iwreq()
        request.setInterfaceName(interface)
        
        guard IOControl(internalSocket, SIOCGIWNAME, &request) != -1
            else { throw POSIXError.fromErrno! }
        
        return "" // FIXME:
    }
    
    internal func wirelessExtensionVersion(for interface: String) throws -> UInt8 {
        
        var result = [iw_range](repeating: iw_range(), count: 2)
        try result.withUnsafeMutableBytes {
            
            var request = iwreq()
            request.setInterfaceName(interface)
            
            request.u.data.pointer = UnsafeMutableRawPointer($0.baseAddress!)
            request.u.data.length = __u16(MemoryLayout<iw_range>.size * 2)
            request.u.data.flags = 0
            
            guard IOControl(internalSocket, SIOCGIWNAME, &request) != -1
                else { throw POSIXError.fromErrno! }
        }
        
        return result[0].we_version_compiled
    }
}

// MARK: - Linux Support

private extension iwreq {
    
    mutating func setInterfaceName(_ name: String) {
        
        name.withCString {
            self.ifr_ifrn.ifrn_name = unsafeBitCast($0, to: UnsafeMutablePointer<(Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8)>.self).pointee
        }
    }
}

#if os(Linux)
    
internal let SOCK_RAW = CInt(Glibc.SOCK_RAW.rawValue)
    
internal let SOCK_STREAM = CInt(Glibc.SOCK_STREAM.rawValue)

internal typealias sa_family_t = Glibc.sa_family_t
    
#elseif os(macOS)
    
internal let AF_PACKET: CInt = 0
    
#endif
