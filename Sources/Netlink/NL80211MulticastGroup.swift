//
//  NL80211MulticastGroup.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/7/18.
//

import Foundation
import CLinuxWLAN

public extension NetlinkGenericMulticastGroupName {
    
    public enum NL80211 {
        
        public static let configuration = NetlinkGenericMulticastGroupName(rawValue: NL80211_MULTICAST_GROUP_CONFIG)
        
        public static let scan = NetlinkGenericMulticastGroupName(rawValue: NL80211_MULTICAST_GROUP_SCAN)
        
        public static let regulatory = NetlinkGenericMulticastGroupName(rawValue: NL80211_MULTICAST_GROUP_REG)
        
        public static let mlme = NetlinkGenericMulticastGroupName(rawValue: NL80211_MULTICAST_GROUP_MLME)
        
        public static let vendor = NetlinkGenericMulticastGroupName(rawValue: NL80211_MULTICAST_GROUP_VENDOR)
        
        //public static let nan = NetlinkGenericMulticastGroupName(rawValue: NL80211_MULTICAST_GROUP_NAN)
        
        public static let testMode = NetlinkGenericMulticastGroupName(rawValue: NL80211_MULTICAST_GROUP_TESTMODE)
    }
}
