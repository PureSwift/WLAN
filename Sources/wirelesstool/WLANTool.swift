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
        
        #if os(macOS)
        let manager = DarwinWLANManager()
        #elseif os(Linux)
        let manager = try await LinuxWLANManager()
        #endif
                
        guard let interface = await manager.interface
            else { throw CommandError.noInterface }
        
        print("Interface: \(interface)")
        let stream = try await manager.scan(with: interface)
        Task {
            try await Task.sleep(nanoseconds: 30 * 1_000_000_000)
            stream.stop()
        }
        print("Networks:")
        var counter = 0
        for try await network in stream {
            counter += 1
            print("\(counter). \(network.ssid) \(network.bssid?.description ?? "")")
        }
        print("Found \(counter) networks")
    }
}
