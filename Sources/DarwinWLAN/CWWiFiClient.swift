//
//  CWWiFiClient.swift
//  WLANDarwin
//
//  Created by Alsey Coleman Miller on 7/5/18.
//

#if os(macOS)

import Foundation
import CoreWLAN
import WLAN

internal extension CWWiFiClient {
    
    func interface(for interface: WLANInterface) throws -> CWInterface {
        
        guard let wlanInterface = self.interfaces()?
            .first(where: { $0.interfaceName == interface.name })
            else { throw WLANError.invalidInterface(interface) }
        
        return wlanInterface
    }
}

#endif
