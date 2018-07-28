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
        ("testGetScanResultsMessage", testGetScanResultsMessage),
        ("testErrorMessage", testErrorMessage)
    ]
    
    func testGetScanResultsMessage() {
        
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
        
         
         Interface: wlx74da3826382c
         Wireless Extension Version: 0
         Wireless Extension Name: IEEE 802.11
         interface 3
         nl80211 NetlinkGenericFamilyIdentifier(rawValue: 28)
         Sent 28 bytes to kernel
         [28, 0, 0, 0, 28, 0, 5, 5, 96, 138, 91, 91, 237, 32, 0, 92, 32, 0, 0, 0, 8, 0, 3, 0, 3, 0, 0, 0]
         Operation not supported
         
        */
        
        let data = Data([28, 0, 0, 0, 28, 0, 1, 5, 0, 0, 0, 0, 47, 104, 0, 0, 32, 0, 0, 0, 8, 0, 3, 0, 3, 0, 0, 0])
        
        guard let message = NetlinkGenericMessage(data: data)
            else { XCTFail(); return }
        
        XCTAssertEqual(message.data, data)
        XCTAssertEqual(message.length, 28)
        XCTAssertEqual(Int(message.length), data.count)
        XCTAssertEqual(message.type.rawValue, 28) // NetlinkGenericFamilyIdentifier(rawValue: 28)
        XCTAssertEqual(message.command.rawValue, NetlinkGenericCommand.NL80211.getScanResults.rawValue)
        XCTAssertEqual(message.version.rawValue, 0)
        XCTAssertEqual(message.flags, [.dump, .request])
        XCTAssertEqual(message.sequence, 0)
        
        //dump(message)
        
        var attributes = [NetlinkAttribute]()
        XCTAssertNoThrow(attributes = try NetlinkAttribute.from(message: message))
        
        guard attributes.count == 1
            else { XCTFail(); return }
        
        XCTAssertEqual(UInt32(attribute: attributes[0]), 3)
        XCTAssertEqual(attributes[0].type.rawValue, NetlinkAttributeType.NL80211.interfaceIndex.rawValue)
        
        // libnl message
        XCTAssertEqual(NetlinkGenericMessage(data: Data([28, 0, 0, 0, 28, 0, 5, 5, 96, 138, 91, 91, 237, 32, 0, 92, 32, 0, 0, 0, 8, 0, 3, 0, 3, 0, 0, 0]))?.flags, [.dump, .acknowledgment, .request])
    }
    
    func testErrorMessage() {
        
        /**
         Interface: wlx74da3826382c
         Wireless Extension Version: 0
         Wireless Extension Name: IEEE 802.11
         interface 3
         nl80211 NetlinkGenericFamilyIdentifier(rawValue: 28)
         Sent 28 bytes to kernel
         [28, 0, 0, 0, 28, 0, 1, 5, 0, 0, 0, 0, 52, 105, 0, 0, 32, 0, 0, 0, 8, 0, 3, 0, 3, 0, 0, 0]
         Recieved 48 bytes from the kernel
         [48, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 52, 105, 0, 0, 161, 255, 255, 255, 28, 0, 0, 0, 28, 0, 1, 5, 0, 0, 0, 0, 52, 105, 0, 0, 32, 0, 0, 0, 8, 0, 3, 0, 3, 0, 0, 0]
         */
        
        let data = Data([48, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 52, 105, 0, 0, 161, 255, 255, 255,
                         28, 0, 0, 0, 28, 0, 1, 5, 0, 0, 0, 0, 52, 105, 0, 0, 32, 0, 0, 0, 8, 0, 3, 0, 3, 0, 0, 0])
        
        guard let error = NetlinkErrorMessage(data: data)
            else { XCTFail("Could not parse message"); return }
        
        //XCTAssertEqual(error.data, data)
        XCTAssertEqual(error.length, 48)
        XCTAssertEqual(Int(error.length), data.count)
        XCTAssertEqual(error.sequence, 0)
        XCTAssertEqual(error.flags, [])
        XCTAssertEqual(error.type, .error)
        XCTAssertEqual(error.error.code.rawValue, 95)
        
        #if os(Linux)
        XCTAssertEqual(error.error.code, .EOPNOTSUPP)
        #endif
    }
}
