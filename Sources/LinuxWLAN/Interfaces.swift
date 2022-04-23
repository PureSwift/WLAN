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
    
    /// Issue NL80211_CMD_GET_INTERFACE to the kernel and get wireless interfaces info.
    func getInterface(_ interface: UInt32) async throws -> NL80211Interface {
        // Setup which command to run.
        let command = NL80211GetInterfaceCommand(id: interface)
        let message = try newMessage(command, flags: [.dump])
        // Send the message.
        try await socket.send(message.data)
        // Retrieve the kernel's answer
        let recievedData = try await socket.recieve()
        let decoder = NetlinkAttributeDecoder()
        // parse response
        guard let messages = try? NetlinkGenericMessage.from(data: recievedData),
            let response = messages.first,
            let interface = try? decoder.decode(NL80211Interface.self, from: response)
            else { throw NetlinkSocketError.invalidData(recievedData) }
        return interface
    }
}
