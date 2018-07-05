//
//  CWNetwork.swift
//  WLANDarwin
//
//  Created by Alsey Coleman Miller on 7/5/18.
//

#if os(macOS)

import Foundation
import CoreWLAN
import WLAN

internal extension WLANNetwork {
    
    init(_ coreWLAN: CWNetwork) {
        
        guard let ssidData = coreWLAN.ssidData,
            let ssid = SSID(data: ssidData),
            let bssidString = coreWLAN.bssid,
            let bssid = BSSID(rawValue: bssidString)
            else { fatalError("Invalid values") }
        
        self.init(ssid: ssid, bssid: bssid)
    }
}

#endif
