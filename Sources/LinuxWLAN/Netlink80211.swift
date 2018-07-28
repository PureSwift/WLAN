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
        
        // WLAN interface
        let interface: WLANInterface
        
        // WLAN interface index
        let interfaceIndex: UInt
        
        // Open socket to kernel
        let socket: NetlinkSocket
        
        // "nl80211" driver ID
        //let driverID: NetlinkGenericFamilyIdentifier
        
        init(interface: WLANInterface) throws {
            
            // Use this wireless interface for scanning.
            let interfaceIndex = try NetworkInterface.index(for: NetworkInterface(name: interface.name))
            
            print("interface \(interfaceIndex)")
            
            // Open socket to kernel.
            // Create file descriptor and bind socket.
            let netlinkSocket = try NetlinkSocket(.generic)
            
            // Find the "nl80211" driver ID.
            //let driverID = try netlinkSocket.genericView.resolve(name: .nl80211)  // Find the "nl80211" driver ID.
            
            //print("nl80211 \(driverID)")
            
            self.interface = interface
            self.interfaceIndex = interfaceIndex
            self.socket = netlinkSocket
            //self.driverID = driverID
        }
        
        /// Issue NL80211_CMD_TRIGGER_SCAN to the kernel and wait for it to finish.
        func triggerScan(with ssid: SSID? = nil) throws {
            
            
        }
        
        /// Issue NL80211_CMD_GET_SCAN.
        func scanResults() throws -> [WLANNetwork] {
            
            var networks = [WLANNetwork]()
            /*
            // Create message
            let message = NetlinkMessage()
            
            // Setup which command to run.
            message.genericView.put(port: 0,
                                    sequence: 0,
                                    family: driverID,
                                    headerLength: 0,
                                    flags: NetlinkMessageFlag.Get.dump,
                                    command: NetlinkGenericCommand.NL80211.getScanResults,
                                    version: 0)
            
            // Add message attribute, specify which interface to use.
            try message.setValue(UInt32(interfaceIndex), for: NetlinkAttribute.NL80211.interfaceIndex)
            
            // Add the callback.
            try socket.modifyCallback(type: NL_CB_VALID, kind: NL_CB_CUSTOM) {
                
                print("Recieved message")
                
                return NL_SKIP
            }
            
            // Send the message.
            let sentBytes = try socket.send(message: message)
            
            print("Sent \(sentBytes) bytes to kernel")
            
            print(message.data.map { $0 })
            
            // Retrieve the kernel's answer
            try socket.recieve()
            */
            
            return networks
        }
    }
}
