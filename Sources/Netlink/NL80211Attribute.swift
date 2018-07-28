//
//  NL80211Attribute.swift
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

public extension NetlinkAttributeType {
    
    /// 802.11 netlink interface
    public enum NL80211 {
        
        public static let wiphy = NetlinkAttributeType(NL80211_ATTR_WIPHY)
        
        public static let wihpyName = NetlinkAttributeType(NL80211_ATTR_WIPHY_NAME)
        
        public static let interfaceIndex = NetlinkAttributeType(NL80211_ATTR_IFINDEX)
        
        public static let interfaceName = NetlinkAttributeType(NL80211_ATTR_IFNAME)
        
        public static let interfaceType = NetlinkAttributeType(NL80211_ATTR_IFTYPE)
        
        public static let macAddress = NetlinkAttributeType(NL80211_ATTR_MAC)
        
        public static let bss = NetlinkAttributeType(NL80211_ATTR_BSS)
        
        /// netlink attributes for a BSS
        public enum BSS {
            
            public static let bssid = NetlinkAttributeType(NL80211_BSS_BSSID)
        }
    }
}

fileprivate extension NetlinkAttributeType {
    
    init(_ nl80211Attribute: nl80211_attrs) {
        
        self.init(rawValue: UInt16(nl80211Attribute.rawValue))
    }
}

fileprivate extension NetlinkAttributeType {
    
    init(_ nl80211Attribute: nl80211_bss) {
        
        self.init(rawValue: UInt16(nl80211Attribute.rawValue))
    }
}
