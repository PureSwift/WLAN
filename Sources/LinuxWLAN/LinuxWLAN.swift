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
import SystemPackage
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
    
    internal private(set) var interfaceCache = [WLANInterface: InterfaceCache]()
    
    internal private(set) var scanCache = [WLANNetwork: NL80211ScanResult]()
    
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
    
    // MARK: - Internal Methods
    
    internal func interface(for interfaceName: WLANInterface) throws -> InterfaceCache {
        guard let interface = interfaceCache[interfaceName] else {
            throw WLANError.invalidInterface(interfaceName)
        }
        return interface
    }
    
    internal func newMessage(
        _ command: NetlinkGenericCommand,
        flags: NetlinkMessageFlag = 0,
        version: NetlinkGenericVersion = 0,
        payload: Data = Data()
    ) -> NetlinkGenericMessage {
        return NetlinkGenericMessage(
            type: NetlinkMessageType(rawValue: UInt16(controller.id.rawValue)),
            flags: flags,
            sequence: newSequence(),
            process: ProcessID.current.rawValue,
            command: command,
            version: version,
            payload: payload
        )
    }
    
    internal func newMessage<T: NetlinkWLANMessage>(
        _ command: T,
        flags: NetlinkMessageFlag = 0
    ) throws -> NetlinkGenericMessage {
        let encoder = NetlinkAttributeEncoder()
        let commandData = try encoder.encode(command)
        return newMessage(T.command, flags: flags, version: T.version, payload: commandData)
    }
    
    private func newSequence() -> UInt32 {
        if sequenceNumber == .max {
            sequenceNumber = 0
        } else {
            sequenceNumber += 1
        }
        return sequenceNumber
    }
    
    internal func refreshInterfaces() async throws {
        let interfaces = try NetworkInterface.interfaces()
        self.interfaceCache.removeAll(keepingCapacity: true)
        self.interfaceCache.reserveCapacity(interfaces.count)
        for interface in interfaces {
            do {
                let key = WLANInterface(name: interface.name)
                let id = try NetworkInterface.index(for: interface)
                let wiphy = try await getWiphy(id)
                let cacheValue = InterfaceCache(
                    id: id,
                    interface: interface,
                    wiphy: wiphy
                )
                self.interfaceCache[key] = cacheValue
            } catch {
                continue
            }
        }
    }
    
    @discardableResult
    internal func cache(_ scanResult: NL80211ScanResult) -> WLANNetwork {
        let ssidLength = min(Int(scanResult.bss.informationElements[1]), 32)
        let ssid = SSID(data: scanResult.bss.informationElements[2 ..< 2 + ssidLength]) ?? ""
        let bssid = BSSID(bigEndian: BSSID(bytes: scanResult.bss.bssid.bytes))
        let network = WLANNetwork(ssid: ssid, bssid: bssid)
        self.scanCache[network] = scanResult
        return network
    }
}

// MARK: - Supporting Types

internal extension LinuxWLANManager {
    
    struct InterfaceCache: Equatable, Hashable, Identifiable {
        
        let id: UInt32
        
        let interface: NetworkInterface
        
        let wiphy: NL80211Wiphy
    }
}

internal protocol NetlinkWLANMessage: Encodable {
    
    static var command: NetlinkGenericCommand { get }
    
    static var version: NetlinkGenericVersion { get }
}

extension NL80211GetWiphyCommand: NetlinkWLANMessage { }

extension NL80211GetInterfaceCommand: NetlinkWLANMessage { }

extension NL80211TriggerScanCommand: NetlinkWLANMessage { }

extension NL80211GetScanResultsCommand: NetlinkWLANMessage { }
