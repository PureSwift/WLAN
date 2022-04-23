//
//  main.swift
//  WLAN
//
//  Created by Alsey Coleman Miller on 7/5/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

#if os(Linux)
import Glibc
#elseif os(macOS)
import Darwin.C
#endif

import Foundation
import WLAN

#if os(macOS)
import DarwinWLAN
#elseif os(Linux)
import LinuxWLAN
#endif

@main
struct WLANTool {

    static func main() async throws {
        
        let manager: WLANManager
        #if os(macOS)
        manager = DarwinWLANManager()
        #elseif os(Linux)
        manager = try await LinuxWLANManager()
        #endif
                
        guard let interface = await manager.interface
            else { throw CommandError.noInterface }
    
        print("Interface: \(interface)")
        let networks = try await manager.scan(for: nil, with: interface)
    
        print("Networks:")
        networks.forEach { print("\($0.ssid) \($0.bssid?.description ?? "")") }
    }
}
