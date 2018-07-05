//
//  Network.swift
//  WLAN
//
//  Created by Alsey Coleman Miller on 7/4/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

import Foundation

/**
 Encapsulates an IEEE 802.11 network. 
 */
public struct WLANNetwork {
    
    /// The service set identifier (SSID) for the network, returned as data.
    ///
    /// The SSID is defined as 1-32 octets.
    public let ssid: SSID
    
    /// The basic service set identifier (BSSID) for the network. 
    public let bssid: BSSID
    
    public init(ssid: SSID,
                bssid: BSSID) {
        
        self.ssid = ssid
        self.bssid = bssid
    }
}

// MARK: - Equatable

extension WLANNetwork: Equatable {
    
    public static func == (rhs: WLANNetwork, lhs: WLANNetwork) -> Bool {
        
        return rhs.ssid == lhs.ssid
            && rhs.bssid == rhs.bssid
    }
}

// MARK: - Hashable

extension WLANNetwork: Hashable {
    
    public var hashValue: Int {
        
        return ssid.hashValue ^ bssid.hashValue
    }
}
