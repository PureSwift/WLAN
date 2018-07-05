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
    
    public let ssid: SSID
    
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
