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
    func scan(with interface: WLANInterface) async throws -> AsyncWLANScan<LinuxWLANManager> {
        do {
            // get cached interface index
            let interface = try self.interface(for: interface)
            // register for `scan` multicast group
            guard let scanGroup = controller.multicastGroups.first(where: { $0.name == NetlinkGenericMulticastGroupName.NL80211.scan })
                else { throw Errno.notSupported }
            // subscribe to group
            try socket.subscribe(to: scanGroup.id)
            // start scanning on wireless interface.
            try await triggerScan(interface: interface.id)
            // reset cache
            resetScanResultsCache()
            // stream
            return AsyncWLANScan { continuation in
                let task = Task {
                    // wait
                    while Task.isCancelled == false {
                        do {
                            // attempt to read messages
                            let messages = try await socket.recieve(NetlinkGenericMessage.self)
                            let hasNewScanResults = messages.contains(where: { $0.command == NetlinkGenericCommand.NL80211.newScanResults })
                            guard hasNewScanResults else {
                                try await Task.sleep(nanoseconds: 100_000_000)
                                continue
                            }
                            let scanResults = try await scanResults(interface: interface.id)
                            // cache new results
                            for scanResult in scanResults {
                                let key = WLANNetwork(scanResult)
                                let isNew = self.scanCache.keys.contains(key) == false
                                self.cache(scanResult)
                                if isNew {
                                    continuation.yield(key)
                                }
                            }
                        }
                        catch _ as NetlinkErrorMessage {
                            continue
                        }
                    }
                }
                continuation.onTermination = { [weak socket] in
                    try? socket?.unsubscribe(from: scanGroup.id)
                    task.cancel()
                }
            }
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
        return messages.compactMap { try? decoder.decode(NL80211ScanResult.self, from: $0) }
    }
}

internal extension WLANNetwork {
    
    init(_ scanResult: NL80211ScanResult) {
        let ssidLength = min(Int(scanResult.bss.informationElements[1]), 32)
        let ssid = SSID(data: scanResult.bss.informationElements[2 ..< 2 + ssidLength]) ?? ""
        let bssid = BSSID(bigEndian: BSSID(bytes: scanResult.bss.bssid.bytes))
        self.init(ssid: ssid, bssid: bssid)
    }
}
