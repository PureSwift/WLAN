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
        ("testMessage", testMessage)
    ]
    
    func testMessage() {
        
        do {
            
            let _ = Data([28, 0, 0, 0, 28, 0, 5, 5, 46, 78, 65, 91, 17, 108, 0, 206, 32, 0, 0, 0, 8, 0, 3, 0, 12, 0, 0, 0])
            
            
        }
    }
}
