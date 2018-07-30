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
import CLinuxWLAN

public final class Netlink80211 {
    
    /**
     Scans for networks.
     
     If ssid parameter is present, a directed scan will be performed by the interface, otherwise a broadcast scan will be performed. This method will block for the duration of the scan.
     
     - Parameter ssid: The SSID for which to scan.
     - Parameter interface: The network interface.
     */
    public func scan(with ssid: SSID?, for interface: WLANInterface) throws -> [WLANNetwork] {
        
        let scanOperation = try ScanOperation(interface: interface)
        
        try scanOperation.triggerScan(with: ssid)
        
        return try scanOperation.scanResults()
    }
}

internal extension Netlink80211 {
    
    final class ScanOperation {
        
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
        
        private func newSequence() -> UInt32 {
            
            sequence += 1
            return sequence
        }
        
        init(interface: WLANInterface) throws {
            
            // Use this wireless interface for scanning.
            let interfaceIndex = try NetworkInterface.index(for: NetworkInterface(name: interface.name))
            
            // Open socket to kernel.
            // Create file descriptor and bind socket.
            let netlinkSocket = try NetlinkSocket(.generic)
            
            // Find the "nl80211" driver ID.
            let driver = try netlinkSocket.resolve(name: .nl80211)  // Find the "nl80211" driver ID.
            
            self.interface = interface
            self.interfaceIndex = interfaceIndex
            self.socket = netlinkSocket
            self.driver = driver
        }
        
        /// Issue NL80211_CMD_TRIGGER_SCAN to the kernel and wait for it to finish.
        func triggerScan(with ssid: SSID? = nil) throws {
            
            // register for `scan` multicast group
            guard let scanGroup = driver.multicastGroups.first(where: { $0.name == NetlinkGenericMulticastGroupName.NL80211.scan })
                else { throw Error.scanningNotSupported }
            
            // subscribe to group
            try socket.subscribe(to: scanGroup.identifier)
            defer { try? socket.unsubscribe(from: scanGroup.identifier) }
            
            // Add message attribute, specify which interface to use.
            let interfaceAttribute = NetlinkAttribute(value: UInt32(interfaceIndex),
                                                      type: NetlinkAttributeType.NL80211.interfaceIndex)
            
            // Setup which command to run.
            let message = NetlinkGenericMessage(type: NetlinkMessageType(rawValue: UInt16(driver.identifier.rawValue)),
                                                flags: [.request],
                                                sequence: newSequence(),
                                                process: getpid(),
                                                command: NetlinkGenericCommand.NL80211.triggerScan,
                                                version: 0,
                                                payload: interfaceAttribute.paddedData)
            
            // Send the message.
            try socket.send(message.data)
            
            var messages = [NetlinkGenericMessage]()
            repeat {
                
                // attempt to read messages
                do { messages += try socket.recieve(NetlinkGenericMessage.self) }
                catch {
                    
                    #if os(Linux)
                    typealias POSIXError = Netlink.POSIXError
                    #endif
                    
                    // try again
                    if let error = error as? POSIXError, error.code == .EBUSY {
                        sleep(1)
                    } else {
                        throw error
                    }
                }
                
            } while (messages.contains(where: { $0.command == NetlinkGenericCommand.NL80211.newScanResults }) == false)
        }
        
        /// Issue NL80211_CMD_GET_SCAN.
        func scanResults() throws -> [WLANNetwork] {
            
            // Add message attribute, specify which interface to use.
            let attribute = NetlinkAttribute(value: UInt32(interfaceIndex),
                                             type: NetlinkAttributeType.NL80211.interfaceIndex)
            
            // Setup which command to run.
            let message = NetlinkGenericMessage(type: NetlinkMessageType(rawValue: UInt16(driver.identifier.rawValue)),
                                                flags: 773,
                                                sequence: newSequence(),
                                                process: getpid(),
                                                command: NetlinkGenericCommand.NL80211.getScan,
                                                version: 0,
                                                payload: attribute.paddedData)
            
            // Send the message.
            try socket.send(message.data)
            
            // Retrieve the kernel's answer
            let messages = try socket.recieve(NetlinkGenericMessage.self)
            
            let decoder = NetlinkAttributeDecoder()
            
            let scanResults = try messages.map { try decoder.decode(NL80211ScanResult.self, from: $0) }
            
            return scanResults.map {
                
                let ssidLength = min(Int($0.bss.informationElements[1]), 32)
                
                let ssid = SSID(data: $0.bss.informationElements[2 ..< 2 + ssidLength]) ?? ""
                
                return WLANNetwork(ssid: ssid, bssid: $0.bss.bssid)
            }
        }
    }
}
