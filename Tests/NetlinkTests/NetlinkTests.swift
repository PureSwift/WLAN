//
//  NetlinkTests.swift
//  PureSwift
//
//  Created by Alsey Coleman Miller on 7/6/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

import Foundation
import XCTest
import WLAN
@testable import LinuxWLAN

final class NetlinkTests: XCTestCase {
    
    static var allTests = [
        ("testSSID", testSSID)
    ]
    
    func testSSID() {
        
        XCTAssertNil(SSID(string: ""), "SSID must be 1-32 octets")
        XCTAssertNil(SSID(string: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua"), "SSID must be 1-32 octets")
        
        XCTAssertEqual(SSID(string: "ColemanCDA")?.description, "ColemanCDA")
        XCTAssertEqual(SSID(string: "ColemanCDA"), "ColemanCDA")
    }
}
