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
#endif

final class WLANTests: XCTestCase {
    
    static var allTests = [
        ("testSSID", testSSID),
        ]
    
    func testSSID() {
        
        XCTAssertNil(SSID(string: ""))
        XCTAssertNil(SSID(string: "Too Long Wifi Network Name Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua"))
        
        XCTAssertEqual(SSID(string: "ColemanCDA")?.description, "ColemanCDA")
        XCTAssertEqual(SSID(string: "ColemanCDA"), "ColemanCDA")
    }
    
    func testBSSID() {
        
        XCTAssertEqual(BSSID(rawValue: "D8:C7:71:41:C1:DB")?.description, "D8:C7:71:41:C1:DB")
        XCTAssertEqual(BSSID(rawValue: "18:A6:F7:99:81:90")?.description, "18:A6:F7:99:81:90")
    }
    
    #if os(macOS)
    func testDarwinWLAN() {
        
        do {
            
            let wlanManager = DarwinWLANManager()
            
            guard let interface = wlanManager.interface
                else { XCTFail(); return }
            
            print("Interface: \(interface)")
            
            let networks = try wlanManager.scan(for: interface)
            
            XCTAssert(networks.isEmpty == false)
            
            print("Networks:")
            networks.forEach { print("\($0.ssid) (\($0.bssid))") }
        }
        
        catch { XCTFail("\(error)"); return }
    }
    #endif
}
