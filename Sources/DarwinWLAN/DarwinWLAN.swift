//
//  CoreWLAN.swift
//  WLAN
//
//  Created by Alsey Coleman Miller on 7/3/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

#if canImport(CoreWLAN)

import Foundation
import CoreWLAN
import WLAN

/// Darwin WLAN Manager
///
/// Query AirPort interfaces and choose wireless networks.
public final class DarwinWLANManager: WLANManager {
    
    // MARK: - Properties
    
    internal let client: CWWiFiClient
    
    // MARK: - Initialization
    
    public init() {
        self.client = CWWiFiClient()
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
     
     - Note: Returned networks will not contain BSSID information unless Location Services is enabled and the user has authorized the calling app to use location services.
     
     - Parameter ssid: The SSID for which to scan.
     - Parameter interface: The network interface.
     */
    public func scan(
        for ssid: SSID? = nil,
        with interface: WLANInterface
    ) async throws -> [WLANNetwork] {
        
        let wlanInterface = try client.interface(for: interface)
        try wlanInterface.scanForNetworks(withSSID: ssid?.data)
        let cachedScanResults = wlanInterface.cachedScanResults() ?? []
        return cachedScanResults
            .lazy
            .map { WLANNetwork($0) }
            .sorted(by: { $0.ssid.description < $1.ssid.description })
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

internal extension DarwinWLANManager {
    
    /// CWWiFiClient Delegate
    ///
    /// https://developer.apple.com/documentation/corewlan/cweventdelegate
    @objc(DarwinWLANManagerDelegate)
    final class Delegate: NSObject /* CWWiFiEventDelegate */ {
        
        private unowned var manager: DarwinWLANManager
        
        init(_ manager: DarwinWLANManager) {
            self.manager = manager
        }
        
        /// Tells the delegate that the current BSSID has changed.
        @objc
        func bssidDidChangeForWiFiInterface(withName name: String) {
            
        }
        
        /// Tells the delegate that the connection to the Wi-Fi subsystem is temporarily interrupted.
        @objc
        func clientConnectionInterrupted() {
            
        }
        
        /// Tells the delegate that the connection to the Wi-Fi subsystem is permanently invalidated.
        @objc
        func clientConnectionInvalidated() {
            
        }
        
        /// Tells the delegate that the currently adopted country code has changed.
        @objc
        func countryCodeDidChangeForWiFiInterface(withName name: String) {
            
        }
        
        /// Tells the delegate that the Wi-Fi link state changed.
        @objc
        func linkDidChangeForWiFiInterface(withName name: String) {
            
        }
        
        /// Tells the delegate that the link quality has changed.
        @objc
        func linkQualityDidChangeForWiFiInterface(withName name: String, rssi: Int, transmitRate: Double) {
            
        }
        
        /// Tells the delegate that the operating mode has changed.
        func modeDidChangeForWiFiInterface(withName name: String) {
            
        }
        
        /// Tells the delegate that the Wi-Fi power state changed.
        func powerStateDidChangeForWiFiInterface(withName name: String) {
            
        }
        
        /// Tells the delegate that the Wi-Fi interface's scan cache has been updated with new results.
        func scanCacheUpdatedForWiFiInterface(withName name: String) {
            
        }
        
        ///
        func ssidDidChangeForWiFiInterface(withName name: String) {
            
        }

    }
}

#endif
