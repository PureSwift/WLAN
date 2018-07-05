//
//  CoreWLAN.swift
//  WLAN
//
//  Created by Alsey Coleman Miller on 7/3/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

#if os(macOS)

import Foundation
import CoreWLAN
import WLAN

/// Darwin WLAN Manager
public final class DarwinWLANManager: NSObject, WLANManager {
    
    // MARK: - Properties
    
    internal let client: CWWiFiClient
    
    // MARK: - Initialization
    
    public override init() {
        
        self.client = CWWiFiClient()! // Apple, please annotate this API
        super.init()
        
        self.client.delegate = self
    }
    
    // MARK: - Methods
    
    /// Returns the default Wi-Fi interface.
    public var interface: WLANInterface? {
        
        guard let interface = client.interface()
            else { return nil }
        
        return WLANInterface(interface)
    }
    
    /**
     Returns all available Wi-Fi interfaces.
     
     - Returns: An array of `WLANInterface`, representing all of the available Wi-Fi interfaces in the system.
     */
    public var interfaces: [WLANInterface] {
        
        return client.interfaces()?.map { WLANInterface($0) } ?? []
    }
    
    /**
     Sets the interface power state.
     
     - Parameter power: A Boolean value corresponding to the power state. NO indicates the "OFF" state.
     - Parameter interface: The network interface.
     */
    public func setPower(_ power: Bool, for interface: WLANInterface) throws {
        
        try client.interface(for: interface).setPower(power)
    }
    
    /**
     Scans for networks.
     
     If ssid parameter is present, a directed scan will be performed by the interface, otherwise a broadcast scan will be performed. This method will block for the duration of the scan.
     
     - Parameter ssid: The SSID for which to scan.
     - Parameter interface: The network interface.
     */
    public func scan(with ssid: SSID? = nil, for interface: WLANInterface) throws -> [WLANNetwork] {
        
        let wlanInterface = try client.interface(for: interface)
            
        try wlanInterface.scanForNetworks(withSSID: ssid?.data)
        
        return wlanInterface.cachedScanResults()?.map { WLANNetwork($0) } ?? []
    }
    
    /**
     Associates to a given network using the given network passphrase.
     
     - Parameter network: The network to which the interface will associate.
     - Parameter password: The network passphrase or key. Required for association to WEP, WPA Personal, and WPA2 Personal networks.
     - Parameter interface: The network interface.
     */
    public func associate(to network: WLANNetwork,
                          password: String? = nil,
                          for interface: WLANInterface) throws {
        
        let wlanInterface = try client.interface(for: interface)
        let wlanNetwork = try wlanInterface.network(for: network)
        
        try wlanInterface.associate(to: wlanNetwork, password: password)
    }
    
    /**
     Disassociates from the current network.
     
     This method has no effect if the interface is not associated to a network.
     */
    public func disassociate(interface: WLANInterface) throws {
        
        try client.interface(for: interface).disassociate()
    }
}

#endif
