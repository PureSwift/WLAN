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

#if os(Linux) || Xcode

import Foundation
import WLAN
import Netlink
import CNetlink
import CSwiftLinuxWLAN

public final class Netlink80211 {
    
    internal func scanResults(for interface: WLANInterface) throws -> [WLANNetwork] {
        
        var networks = [WLANNetwork]()
        
        // Use this wireless interface for scanning.
        let interfaceIndex = try NetworkInterface.index(for: NetworkInterface(name: interface.name))
        
        // Open socket to kernel.
        let netlinkSocket = NetlinkSocket()
        
        // Create file descriptor and bind socket.
        try netlinkSocket.connect(using: .generic)
        
        let driverID = try netlinkSocket.genericView.resolve(name: .nl80211)  // Find the "nl80211" driver ID.
        
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
        try netlinkSocket.modifyCallback(type: NL_CB_VALID, kind: NL_CB_CUSTOM) {
            
            print("Recieved message")
            
            return NL_SKIP
        }
        
        // Send the message.
        let sentBytes = try netlinkSocket.send(message: message)
        
        print("Sent \(sentBytes) bytes to kernel")
        
        // Retrieve the kernel's answer
        try netlinkSocket.recieve()
        
        return networks
    }
}

#endif
