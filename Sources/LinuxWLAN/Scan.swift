//
//  Netlink80211.swift
//  LinuxWLAN
//
//  Created by Alsey Coleman Miller on 7/7/18.
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

public extension LinuxWLANManager {
    
    /**
     Scans for networks.
     
     If ssid parameter is present, a directed scan will be performed by the interface, otherwise a broadcast scan will be performed. This method will block for the duration of the scan.
     
     - Parameter ssid: The SSID for which to scan.
     - Parameter interface: The network interface.
     */
    func scan(for ssid: SSID? = nil, with interface: WLANInterface) async throws -> [WLANNetwork] {
        do {
            // Use this wireless interface for scanning.
            let interfaceIndex = try NetworkInterface.index(for: NetworkInterface(name: interface.name))
            try await triggerScan(with: ssid, interface: interfaceIndex)
            return try await scanResults(interface: interfaceIndex)
        }
        catch let error as NetlinkErrorMessage {
            throw error.error ?? error
        }
    }
}

internal extension LinuxWLANManager {
    
    /// Issue NL80211_CMD_TRIGGER_SCAN to the kernel and wait for it to finish.
    func triggerScan(with ssid: SSID? = nil, interface interfaceIndex: UInt) async throws {
        
        // register for `scan` multicast group
        guard let scanGroup = controller.multicastGroups.first(where: { $0.name == NetlinkGenericMulticastGroupName.NL80211.scan })
            else { throw Errno.notSupported }
        
        // subscribe to group
        try socket.subscribe(to: scanGroup.identifier)
        defer { try? socket.unsubscribe(from: scanGroup.identifier) }
        
        let command = NL80211TriggerScanCommand(interface: UInt32(interfaceIndex))
        let encoder = NetlinkAttributeEncoder()
        let commandData = try encoder.encode(command)
        
        // Setup which command to run.
        let message = NetlinkGenericMessage(type: NetlinkMessageType(rawValue: UInt16(controller.identifier.rawValue)),
                                            flags: [.request],
                                            sequence: newSequence(),
                                            process: getpid(),
                                            command: NetlinkGenericCommand.NL80211.triggerScan,
                                            version: 0,
                                            payload: commandData)
        
        // Send the message.
        try await socket.send(message.data)
        
        var messages = [NetlinkGenericMessage]()
        repeat {
            // attempt to read messages
            messages += try await socket.recieve(NetlinkGenericMessage.self)
        } while (messages.contains(where: { $0.command == NetlinkGenericCommand.NL80211.newScanResults }) == false)
    }
    
    /// Issue NL80211_CMD_GET_SCAN.
    func scanResults(interface interfaceIndex: UInt) async throws -> [WLANNetwork] {
        
        // Add message attribute, specify which interface to use.
        let command = NL80211GetScanResultsCommand(interface: UInt32(interfaceIndex))
        let encoder = NetlinkAttributeEncoder()
        let commandData = try encoder.encode(command)
        
        // Setup which command to run.
        let message = NetlinkGenericMessage(type: NetlinkMessageType(rawValue: UInt16(controller.identifier.rawValue)),
                                            flags: 773,
                                            sequence: newSequence(),
                                            process: getpid(),
                                            command: NetlinkGenericCommand.NL80211.getScan,
                                            version: 0,
                                            payload: commandData)
        
        // Send the message.
        try await socket.send(message.data)
        
        // Retrieve the kernel's answer
        let messages = try await socket.recieve(NetlinkGenericMessage.self)
        let decoder = NetlinkAttributeDecoder()
        let scanResults = try messages.map { try decoder.decode(NL80211ScanResult.self, from: $0) }
        
        return scanResults.map {
            let ssidLength = min(Int($0.bss.informationElements[1]), 32)
            let ssid = SSID(data: $0.bss.informationElements[2 ..< 2 + ssidLength]) ?? ""
            return WLANNetwork(ssid: ssid, bssid: BSSID(bigEndian: BSSID(bytes: $0.bss.bssid.bytes)))
        }
    }
}
