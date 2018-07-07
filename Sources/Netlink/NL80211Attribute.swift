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

#if os(Linux) || Xcode

import Foundation
import CNetlink
import CSwiftLinuxWLAN

public extension NetlinkAttribute {
    
    /// 802.11 netlink interface
    public enum NL80211 {
        
        public static let wiphy = NetlinkAttribute(NL80211_ATTR_WIPHY)
        
        public static let wihpyName = NetlinkAttribute(NL80211_ATTR_WIPHY_NAME)
        
        public static let interfaceIndex = NetlinkAttribute(NL80211_ATTR_IFINDEX)
        
        public static let interfaceName = NetlinkAttribute(NL80211_ATTR_IFNAME)
        
        public static let interfaceType = NetlinkAttribute(NL80211_ATTR_IFTYPE)
        
        public static let macAddress = NetlinkAttribute(NL80211_ATTR_MAC)
    }
}

fileprivate extension NetlinkAttribute {
    
    init(_ nl80211Attribute: nl80211_attrs) {
        
        self.init(rawValue: Int32(nl80211Attribute.rawValue))
    }
}

#endif
