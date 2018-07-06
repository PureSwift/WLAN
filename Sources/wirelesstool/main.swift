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

func run(arguments: [String] = CommandLine.arguments) throws {
    
    //  first argument is always the current directory
    //let arguments = Array(arguments.dropFirst())
    
    #if os(macOS)
    let wlanManager = DarwinWLANManager()
    #elseif os(Linux)
    let wlanManager = try LinuxWLANManager()
    #endif
    
    guard let interface = wlanManager.interface
        else { throw CommandError.noInterface }
    
    print("Interface: \(interface)")
    
    #if os(Linux)
    let version = try wlanManager.wirelessExtensionVersion(for: interface)
    print("Wireless Extension Version: \(version)")
    let name = try wlanManager.wirelessExtensionName(for: interface)
    print("Wireless Extension Name: \(name)")
    #endif
    
    let networks = try wlanManager.scan(with: nil, for: interface)
    
    print("Networks:")
    networks.forEach { print("\($0.ssid) (\($0.bssid))") }
}

do { try run() }
    
catch {
    print("\(error)")
    exit(1)
}
