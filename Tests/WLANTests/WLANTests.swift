//
//  WLANTests.swift
//  PureSwift
//
//  Created by Alsey Coleman Miller on 7/3/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

import Foundation
import XCTest
@testable import WLAN

#if os(macOS)
@testable import DarwinWLAN
#elseif os(Linux)
@testable import LinuxWLAN
#endif

final class WLANTests: XCTestCase {
    
    static var allTests = [
        ("testSSID", testSSID),
        ("testBSSID", testBSSID),
        ("testWLAN", testWLAN)
        ]
    
    func testSSID() {
        
        XCTAssertNil(SSID(string: ""), "SSID must be 1-32 octets")
        XCTAssertNil(SSID(string: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua"), "SSID must be 1-32 octets")
        
        XCTAssertEqual(SSID(string: "ColemanCDA")?.description, "ColemanCDA")
        XCTAssertEqual(SSID(string: "ColemanCDA"), "ColemanCDA")
    }
    
    func testBSSID() {
        
        XCTAssertNil(BSSID(rawValue: ""))
        XCTAssertNil(BSSID(rawValue: "D8C77141C1DB"))
        XCTAssertNil(BSSID(rawValue: "D8:C7:71:41:C1:DB:"))
        
        XCTAssertEqual(BSSID(rawValue: "D8:C7:71:41:C1:DB")?.description, "D8:C7:71:41:C1:DB")
        XCTAssertEqual(BSSID(rawValue: "18:A6:F7:99:81:90")?.description, "18:A6:F7:99:81:90")
    }
    
    func testWLAN() {
        
        do {
            
            #if os(Linux)
            let networkInterfaces = try NetworkInterface.interfaces()
            print("Network Interfaces:")
            networkInterfaces.forEach { print($0.name) }
            #endif
            
            #if os(macOS)
            let wlanManager = DarwinWLANManager()
            #elseif os(Linux)
            let wlanManager = try LinuxWLANManager()
            #endif
            
            guard let interface = wlanManager.interface
                else { XCTFail(); return }
            
            print("Interface: \(interface)")
            
            #if os(Linux)
            let version = try wlanManager.wirelessExtensionVersion(for: interface.name)
            print("Wireless Extension Version: \(version)")
            let name = try wlanManager.wirelessExtensionName(for: interface.name)
            print("Wireless Extension Name: \(name)")
            #endif
            
            let networks = try wlanManager.scan(with: nil, for: interface)
            
            XCTAssert(networks.isEmpty == false)
            
            print("Networks:")
            networks.forEach { print("\($0.ssid) (\($0.bssid))") }
        }
        
        catch { XCTFail("\(error)"); return }
    }
}
