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
import Netlink
import NetlinkGeneric
import Netlink80211

/**
 Linux WLAN Manager
 
 A wrapper around the entire Wi-Fi subsystem that you use to access interfaces.
 */
public actor LinuxWLANManager: WLANManager {
    
    // MARK: - Properties
    
    internal let socket: NetlinkSocket
    
    internal let controller: NetlinkGenericFamilyController
    
    internal private(set) var sequenceNumber: UInt32 = 0
    
    internal private(set) var interfaceCache = [WLANInterface: NL80211Interface]()
    
    // MARK: - Initialization
    
    public init() async throws {
        // Open socket to kernel.
        // Create file descriptor and bind socket.
        let socket = try await NetlinkSocket(.generic)
        // Find the "nl80211" driver ID.
        let controller = try await socket.resolve(name: .nl80211)  // Find the "nl80211" driver ID.
        self.socket = socket
        self.controller = controller
    }
    
    // MARK: - Methods
    
    /// Returns the default Wi-Fi interface.
    public var interface: WLANInterface? {
        get async {
            return await interfaces.first
        }
    }
    
    /**
     Returns all available Wi-Fi interfaces.
     
     - Returns: An array of `WLANInterface`, representing all of the available Wi-Fi interfaces in the system.
     */
    public var interfaces: [WLANInterface] {
        get async {
            do {
                try await refreshInterfaces()
                return interfaceCache
                    .lazy
                    .sorted(by: { $0.value.id < $1.value.id })
                    .map { $0.key }
            }
            catch {
                assertionFailure("Unable to get interfaces. \(error.localizedDescription)")
                return []
            }
        }
    }
    
    internal func refreshInterfaces() async throws {
        let interfaces = try await getInterfaces()
        var cache = [WLANInterface: NL80211Interface]()
        cache.reserveCapacity(interfaces.count)
        for interface in interfaces {
            let key = WLANInterface(name: interface.name)
            cache[key] = interface
        }
        self.interfaceCache = cache
    }
    
    /**
     Sets the interface power state.
     
     - Parameter power: A Boolean value corresponding to the power state. NO indicates the "OFF" state.
     - Parameter interface: The network interface.
     */
    public func setPower(_ power: Bool, for interface: WLANInterface) throws {
        
    }
    
    /**
     Disassociates from the current network.
     
     This method has no effect if the interface is not associated to a network.
     */
    public func disassociate(interface: WLANInterface) throws {
        
    }
    
    // MARK: - Private Methods
    
    internal func newSequence() -> UInt32 {
        if sequenceNumber == .max {
            sequenceNumber = 0
        } else {
            sequenceNumber += 1
        }
        return sequenceNumber
    }
}

