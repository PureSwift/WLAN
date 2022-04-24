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
    
    /// Issue NL80211_CMD_GET_WIPHY to the kernel and get wireless info.
    func getWiphy(_ interface: UInt32) async throws -> NL80211Wiphy {
        // Setup which command to run.
        let command = NL80211GetWiphyCommand(interface: interface)
        let message = try newMessage(command, flags: [.request])
        // Send the message.
        try await socket.send(message.data)
        // Retrieve the kernel's answer
        let messages = try await socket.recieve(NetlinkGenericMessage.self)
        let decoder = NetlinkAttributeDecoder()
        // parse response
        guard let response = messages.first,
            let interface = try? decoder.decode(NL80211Wiphy.self, from: response)
            else { throw NetlinkSocketError.invalidData(Data()) }
        return interface
    }
}
