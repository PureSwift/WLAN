//
//  CWNetwork.swift
//  WLANDarwin
//
//  Created by Alsey Coleman Miller on 7/5/18.
//

#if canImport(CoreWLAN)

import Foundation
import CoreWLAN
import WLAN

internal extension WLANNetwork {
    
    init(_ coreWLAN: CWNetwork) {
        
        guard let ssidData = coreWLAN.ssidData,
            let ssid = SSID(data: ssidData)
            else { fatalError("Invalid values") }
        
        let bssid: BSSID
        if let bssidString = coreWLAN.bssid {
            bssid = BSSID(rawValue: bssidString) ?? .zero
        } else {
            bssid = .zero // dont have permissions
        }
        
        self.init(ssid: ssid, bssid: bssid)
    }
}

#endif
