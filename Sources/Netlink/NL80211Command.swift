//
//  NL80211Command.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/7/18.
//

#if os(Linux)
import Glibc
#elseif os(macOS) || os(iOS)
import Darwin.C
#endif

import Foundation
import CLinuxWLAN

public extension NetlinkGenericCommand {
    
    /// 802.11 netlink interface
    public enum NL80211 {
        
        public static let triggerScan = NetlinkGenericCommand(NL80211_CMD_TRIGGER_SCAN)
        
        public static let getScan = NetlinkGenericCommand(NL80211_CMD_GET_SCAN)
        
        public static let newScanResults = NetlinkGenericCommand(NL80211_CMD_NEW_SCAN_RESULTS)
    }
}

fileprivate extension NetlinkGenericCommand {
    
    init(_ nl80211Command: nl80211_commands) {
        
        self.init(rawValue: UInt8(nl80211Command.rawValue))
    }
}
