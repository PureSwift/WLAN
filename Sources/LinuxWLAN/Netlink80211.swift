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
import WLAN
import Netlink
import NetlinkGeneric
import Netlink80211

internal extension LinuxWLANManager {
    
    struct ScanOperation {
        
        enum Error: Swift.Error {
            
            case invalidResponse
            case scanningNotSupported
        }
        
        // WLAN interface
        let interface: WLANInterface
        
        // WLAN interface index
        let interfaceIndex: UInt
        
        // Open socket to kernel
        let socket: NetlinkSocket
        
        // "nl80211" driver ID
        let driver: NetlinkGenericFamilyController
        
        private var sequence: UInt32 = 0
        
        private mutating func newSequence() -> UInt32 {
            sequence += 1
            return sequence
        }
        
        init(interface: WLANInterface) async throws {
            
            // Use this wireless interface for scanning.
            let interfaceIndex = try NetworkInterface.index(for: NetworkInterface(name: interface.name))
            
            // Open socket to kernel.
            // Create file descriptor and bind socket.
            let netlinkSocket = try await NetlinkSocket(.generic)
            
            // Find the "nl80211" driver ID.
            let driver = try await netlinkSocket.resolve(name: .nl80211)  // Find the "nl80211" driver ID.
            
            self.interface = interface
            self.interfaceIndex = interfaceIndex
            self.socket = netlinkSocket
            self.driver = driver
        }
        
        /// Issue NL80211_CMD_TRIGGER_SCAN to the kernel and wait for it to finish.
        mutating func triggerScan(with ssid: SSID? = nil) async throws {
            
            // register for `scan` multicast group
            guard let scanGroup = driver.multicastGroups.first(where: { $0.name == NetlinkGenericMulticastGroupName.NL80211.scan })
                else { throw Error.scanningNotSupported }
            
            // subscribe to group
            try socket.subscribe(to: scanGroup.identifier)
            defer { try? socket.unsubscribe(from: scanGroup.identifier) }
            
            let command = NL80211TriggerScanCommand(interface: UInt32(interfaceIndex))
            let encoder = NetlinkAttributeEncoder()
            let commandData = try encoder.encode(command)
            
            // Setup which command to run.
            let message = NetlinkGenericMessage(type: NetlinkMessageType(rawValue: UInt16(driver.identifier.rawValue)),
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
        mutating func scanResults() async throws -> [WLANNetwork] {
            
            // Add message attribute, specify which interface to use.
            let command = NL80211GetScanResultsCommand(interface: UInt32(interfaceIndex))
            let encoder = NetlinkAttributeEncoder()
            let commandData = try encoder.encode(command)
            
            // Setup which command to run.
            let message = NetlinkGenericMessage(type: NetlinkMessageType(rawValue: UInt16(driver.identifier.rawValue)),
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
}
