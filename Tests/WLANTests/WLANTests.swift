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

final class WLANTests: XCTestCase {
    
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
}
