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
            
            let wlanInterface = WLANInterface(name: interface.name)
            
            do { let _ = try wirelessExtensionName(for: wlanInterface) }
            catch { continue }
            
            wlanInterfaces.append(wlanInterface)
        }
        
        return wlanInterfaces
    }
}

internal extension LinuxWLANManager {
    
    enum Mode {
        
        case auto
        case adhoc
        case managed
        case master
        case repeater
        case secondary
        case monitor
    }
}

// MARK: - Linux Support

internal extension iwreq {
    
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
    
internal var AF_PACKET: CInt { fatalError("\(#function) is only availible on Linux") }

#endif
