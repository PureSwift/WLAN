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
     
     - Parameter interface: The network interface.
     */
    func scan(with interface: WLANInterface) async throws -> [WLANNetwork] {
        do {
            // get cached interface index
            let interface = try self.interface(for: interface)
            
            // register for `scan` multicast group
            guard let scanGroup = controller.multicastGroups.first(where: { $0.name == NetlinkGenericMulticastGroupName.NL80211.scan })
                else { throw Errno.notSupported }
        
            // subscribe to group
            try socket.subscribe(to: scanGroup.identifier)
            do {
                // stop listening to scan results
                defer { try? socket.unsubscribe(from: scanGroup.identifier) }
                
                // start scanning on wireless interface.
                try await triggerScan(interface: interface.id)
                
                // wait
                var messages = [NetlinkGenericMessage]()
                repeat {
                    do {
                        // attempt to read messages
                        messages += try await socket.recieve(NetlinkGenericMessage.self)
                    }
                    catch _ as NetlinkErrorMessage {
                        continue
                    }
                } while (messages.contains(where: { $0.command == NetlinkGenericCommand.NL80211.newScanResults }) == false)
            }
            
            // collect results
            let scanResults = try await scanResults(interface: interface.id)
            return scanResults.map { self.cache($0) }
        }
        catch let errorMessage as NetlinkErrorMessage {
            throw errorMessage.error ?? errorMessage
        }
    }
}

internal extension LinuxWLANManager {
    
    /// Issue NL80211_CMD_TRIGGER_SCAN to the kernel and wait for it to finish.
    func triggerScan(interface: UInt32) async throws {
        
        // build command
        let command = NL80211TriggerScanCommand(interface: interface)
        
        // Setup which command to run.
        let message = try newMessage(command, flags: [.request])
        
        // Send the message.
        try await socket.send(message.data)
    }
    
    /// Issue NL80211_CMD_GET_SCAN.
    func scanResults(interface: UInt32) async throws -> [NL80211ScanResult] {
        
        // Add message attribute, specify which interface to use.
        let command = NL80211GetScanResultsCommand(interface: interface)
        
        // Setup which command to run.
        let message = try newMessage(command, flags: 773)
        
        // Send the message.
        try await socket.send(message.data)
        
        // Retrieve the kernel's answer
        let messages = try await socket.recieve(NetlinkGenericMessage.self)
        let decoder = NetlinkAttributeDecoder()
        return try messages.map { try decoder.decode(NL80211ScanResult.self, from: $0) }
    }
}
