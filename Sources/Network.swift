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
    
    public let ssid: Data
    
    public init(ssid: Data) {
        
        self.ssid = ssid
    }
}

// MARK: - Equatable

extension WLANNetwork: Equatable {
    
    public static func == (rhs: WLANNetwork, lhs: WLANNetwork) -> Bool {
        
        return rhs.ssid == lhs.ssid
    }
}

// MARK: - Hashable

extension WLANNetwork: Hashable {
    
    public var hashValue: Int {
        
        return ssid.hashValue
    }
}
