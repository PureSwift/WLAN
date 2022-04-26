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
    
    internal let queue = DispatchQueue(label: "org.pureswift.DarwinWLAN")
    
    // MARK: - Initialization
    
    deinit {
        client.delegate = nil
    }
    
    public init() {
        self.client = CWWiFiClient()
        self.client.delegate = self
    }
    
    // MARK: - Methods
    
    /// Returns the default Wi-Fi interface.
    public var interface: WLANInterface? {
        get async {
            return await withCheckedContinuation { continuation in
                queue.async { [unowned self] in
                    let interface = self.client.interface()
                        .map { WLANInterface($0) }
                    continuation.resume(returning: interface)
                }
            }
        }
    }
    
    /**
     Returns all available Wi-Fi interfaces.
     
     - Returns: An array of `WLANInterface`, representing all of the available Wi-Fi interfaces in the system.
     */
    public var interfaces: [WLANInterface] {
        get async {
            return await withCheckedContinuation { continuation in
                queue.async { [unowned self] in
                    let interfaces = (self.client.interfaces() ?? [])
                        .map { WLANInterface($0) }
                    continuation.resume(returning: interfaces)
                }
            }
        }
    }
    
    /**
     Sets the interface power state.
     
     - Parameter power: A Boolean value corresponding to the power state. NO indicates the "OFF" state.
     - Parameter interface: The network interface.
     */
    public func setPower(_ power: Bool, for interface: WLANInterface) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async { [unowned self] in
                do {
                    let interface = try self.client.interface(for: interface)
                    try interface.setPower(power)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /**
     Scans for networks.
     
     If ssid parameter is present, a directed scan will be performed by the interface, otherwise a broadcast scan will be performed. This method will block for the duration of the scan.
     
     - Note: Returned networks will not contain BSSID information unless Location Services is enabled and the user has authorized the calling app to use location services.
     
     - Parameter ssid: The SSID for which to scan.
     - Parameter interface: The network interface.
     */
    public func scan(
        with interface: WLANInterface
    ) async throws -> AsyncWLANScan<DarwinWLANManager> {
        return AsyncWLANScan { continuation in
            let task = Task {
                var foundNetworks = Set<WLANNetwork>()
                while Task.isCancelled == false {
                    do {
                        let networks = try await self._scan(with: interface)
                        for network in networks {
                            // yield new values only
                            guard foundNetworks.contains(network) == false else {
                                return
                            }
                            foundNetworks.insert(network)
                            continuation.yield(network)
                        }
                    }
                    catch {
                        continuation.finish(throwing: error)
                    }
                }
            }
            // make child task, cancel
            continuation.onTermination = {
                task.cancel()
            }
        }
    }
    
    internal func _scan(
        with interface: WLANInterface
    ) async throws -> Set<WLANNetwork> {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async { [unowned self] in
                do {
                    let interface = try self.client.interface(for: interface)
                    let networks = try interface.scanForNetworks(withSSID: nil) // blocking call
                    let value = Set(networks.lazy.map({ WLANNetwork($0) }))
                    continuation.resume(returning: value)
                }
                catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /**
     Associates to a given network using the given network passphrase.
     
     - Parameter network: The network to which the interface will associate.
     - Parameter password: The network passphrase or key. Required for association to WEP, WPA Personal, and WPA2 Personal networks.
     - Parameter interface: The network interface.
     */
    public func associate(
        to network: WLANNetwork,
        password: String? = nil,
        for interface: WLANInterface
    ) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async { [unowned self] in
                do {
                    let interface = try self.client.interface(for: interface)
                    let network = try interface.network(for: network)
                    try interface.associate(to: network, password: password)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /**
     Disassociates from the current network.
     
     This method has no effect if the interface is not associated to a network.
     */
    public func disassociate(interface: WLANInterface) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async { [unowned self] in
                do {
                    let interface = try self.client.interface(for: interface)
                    interface.disassociate()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
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
