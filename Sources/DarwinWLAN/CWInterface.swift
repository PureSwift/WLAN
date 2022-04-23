//
//  CWInterface.swift
//  WLANDarwin
//
//  Created by Alsey Coleman Miller on 7/5/18.
//

#if canImport(CoreWLAN)

import Foundation
import CoreWLAN
import WLAN

internal extension WLANInterface {
    
    init(_ coreWLAN: CWInterface) {
        
        guard let interfaceName = coreWLAN.interfaceName
            else { fatalError("Invalid values") }
        
        self.init(name: interfaceName)
    }
}

internal extension CWInterface {
    
    func network(for network: WLANNetwork) throws -> CWNetwork {
        
        guard let wlanNetwork = self.cachedScanResults()?
            .first(where: { $0.ssidData == network.ssid.data })
            else { throw WLANError.invalidNetwork(network) }
        
        return wlanNetwork
    }
}

#endif
