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
@testable import Netlink

final class NetlinkTests: XCTestCase {
    
    static var allTests = [
        ("testMessage", testMessage)
    ]
    
    func testMessage() {
        
        /**
        // Setup which command to run.
        message.genericView.put(port: 0,
                                sequence: 0,
                                family: driverID,
                                headerLength: 0,
                                flags: NetlinkMessageFlag.Get.dump,
                                command: NetlinkGenericCommand.NL80211.getScanResults,
                                version: 0)
        
        // Add message attribute, specify which interface to use.
        try message.setValue(UInt32(interfaceIndex), for: NetlinkAttribute.NL80211.interfaceIndex)
        
         coleman@ubuntu:~/Desktop/Parallels Shared Folders/Developer/WLAN$ sudo .build/debug/wirelesstool
         Interface: wlx74da3826382c
         Wireless Extension Version: 0
         Wireless Extension Name: IEEE 802.11
         interface 3
         nl80211 NetlinkGenericFamilyIdentifier(rawValue: 28)
         Sent 28 bytes to kernel
         [28, 0, 0, 0, 28, 0, 5, 5, 94, 138, 91, 91, 227, 32, 128, 91, 32, 0, 0, 0, 8, 0, 3, 0, 3, 0, 0, 0]
         Operation not supported
         
         coleman@ubuntu:~/Desktop/Parallels Shared Folders/Developer/WLAN$ sudo .build/debug/wirelesstool
         Interface: wlx74da3826382c
         Wireless Extension Version: 0
         Wireless Extension Name: IEEE 802.11
         interface 3
         nl80211 NetlinkGenericFamilyIdentifier(rawValue: 28)
         Sent 28 bytes to kernel
         [28, 0, 0, 0, 28, 0, 5, 5, 95, 138, 91, 91, 232, 32, 192, 91, 32, 0, 0, 0, 8, 0, 3, 0, 3, 0, 0, 0]
         Operation not supported
         
         coleman@ubuntu:~/Desktop/Parallels Shared Folders/Developer/WLAN$ sudo .build/debug/wirelesstool
         Interface: wlx74da3826382c
         Wireless Extension Version: 0
         Wireless Extension Name: IEEE 802.11
         interface 3
         nl80211 NetlinkGenericFamilyIdentifier(rawValue: 28)
         Sent 28 bytes to kernel
         [28, 0, 0, 0, 28, 0, 5, 5, 96, 138, 91, 91, 237, 32, 0, 92, 32, 0, 0, 0, 8, 0, 3, 0, 3, 0, 0, 0]
         Operation not supported

        */
        
        let data = Data([28, 0, 0, 0, 28, 0, 5, 5, 96, 138, 91, 91, 237, 32, 0, 92, 32, 0, 0, 0, 8, 0, 3, 0, 3, 0, 0, 0])
        
        guard let message = NetlinkMessage(data: data)
            else { XCTFail(); return }
        
        XCTAssertEqual(message.length, 28)
        XCTAssertEqual(Int(message.length), data.count)
        //XCTAssertEqual(message.flags, NetlinkMessageFlag.Get.dump)
        //XCTAssertEqual(message.sequence, 0)
        
        dump(message)
    }
}
