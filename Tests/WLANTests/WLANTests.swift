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
    
    static var allTests = [
        ("testDarwinWLAN", testDarwinWLAN),
        ]
    
    func testDarwinWLAN() {
        
        do {
            
            let wlanManager = DarwinWLAN()
            
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
}
