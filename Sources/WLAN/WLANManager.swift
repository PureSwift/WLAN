//
//  WLANProtocol.swift
//  WLAN
//
//  Created by Alsey Coleman Miller on 7/4/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

import Foundation

/**
 WLAN Manager
 
 A wrapper around the entire Wi-Fi subsystem that you use to access interfaces.
 */
public protocol WLANManager: AnyObject {
    
    /// Returns the default Wi-Fi interface.
    var interface: WLANInterface? { get async }
    
    /**
     Returns all available Wi-Fi interfaces.
     
     - Returns: An array of `WLANInterface`, representing all of the available Wi-Fi interfaces in the system.
     */
    var interfaces: [WLANInterface] { get async }
    
    /**
     Scans for networks.
     
     If ssid parameter is present, a directed scan will be performed by the interface, otherwise a broadcast scan will be performed. This method will block for the duration of the scan.
     
     - Parameter interface: The network interface.
     */
    func scan(with interface: WLANInterface) async throws -> [WLANNetwork]
    
    /**
     Sets the interface power state.
     
     - Parameter power: A Boolean value corresponding to the power state. NO indicates the "OFF" state.
     - Parameter interface: The network interface.
     */
    func setPower(_ power: Bool, for interface: WLANInterface) async throws
    
    /**
     Disassociates from the current network.
     
     This method has no effect if the interface is not associated to a network.
     */
    func disassociate(interface: WLANInterface) async throws
}
