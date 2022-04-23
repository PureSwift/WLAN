//
//  File.swift
//  
//
//  Created by Alsey Coleman Miller on 4/22/22.
//

import Foundation
import SystemPackage
import WLAN
import Netlink
import NetlinkGeneric
import Netlink80211

internal extension LinuxWLANManager {
    
    /// Issue NL80211_CMD_GET_INTERFACE to the kernel and get wireless interfaces.
    func getInterfaces() async throws -> [NL80211Interface] {
        
        // Setup which command to run.
        let message = newMessage(NetlinkGenericCommand.NL80211.getInterface, flags: [.dump])
        
        // Send the message.
        try await socket.send(message.data)
        
        // Retrieve the kernel's answer
        let messages = try await socket.recieve(NetlinkGenericMessage.self)
        let decoder = NetlinkAttributeDecoder()
        return try messages.map { try decoder.decode(NL80211Interface.self, from: $0) }
    }
}
