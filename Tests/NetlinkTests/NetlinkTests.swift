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
import CLinuxWLAN
@testable import Netlink

final class NetlinkTests: XCTestCase {
    
    static var allTests = [
        ("testResolveGenericFamilyCommand", testResolveGenericFamilyCommand),
        ("testResolveGenericFamilyResponse", testResolveGenericFamilyResponse),
        ("testGetScanResultsCommand", testGetScanResultsCommand),
        ("testNewScanResults", testNewScanResults),
        ("testScanData", testScanData),
        ("testTriggerScanResponse", testTriggerScanResponse),
        ("testErrorMessage", testErrorMessage)
    ]
    
    func testResolveGenericFamilyCommand() {
        
        /**
         Interface: wlx74da3826382c
         Wireless Extension Version: 0
         Wireless Extension Name: IEEE 802.11
         Resolve identifier for NetlinkGenericFamilyName(rawValue: "nl80211")
         [32, 0, 0, 0, 16, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 1, 0, 0, 12, 0, 2, 0, 110, 108, 56, 48, 50, 49, 49, 0]
         */
        
        let data = Data([32, 0, 0, 0, 16, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 1, 0, 0, 12, 0, 2, 0, 110, 108, 56, 48, 50, 49, 49, 0])
        
        guard let message = NetlinkGenericMessage(data: data)
            else { XCTFail("Could not parse message from data"); return }
        
        XCTAssertEqual(message.data, data)
        XCTAssertEqual(Int(message.length), data.count)
        XCTAssertEqual(message.length, 32)
        XCTAssertEqual(message.type.rawValue, UInt16(GENL_ID_CTRL))
        XCTAssertEqual(message.command, .getFamily)
        XCTAssertEqual(message.version.rawValue, 1)
        XCTAssertEqual(message.flags.rawValue, 1)
        XCTAssertEqual(message.sequence, 0)
        
        do {
            
            var decoder = NetlinkAttributeDecoder()
            decoder.log = { print("Decoder:", $0) }
            let command = try decoder.decode(NetlinkGetGenericFamilyIdentifierCommand.self, from: message)
            
            XCTAssertEqual(command.name, .nl80211)
        }
            
        catch { XCTFail("Could not decode: \(error)"); return }
        
        do {
            
            let value = NetlinkGetGenericFamilyIdentifierCommand(name: .nl80211)
            
            var encoder = NetlinkAttributeEncoder()
            encoder.log = { print("Encoder:", $0) }
            
            let data = try encoder.encode(value)
            
            XCTAssertEqual(message.payload, data)
        }
        
        catch { XCTFail("Could not encode: \(error)"); return }
    }
    
    func testResolveGenericFamilyResponse() {
        
        /**
         Interface: wlx74da3826382c
         Wireless Extension Version: 0
         Wireless Extension Name: IEEE 802.11
         Received 2176 from kernel
         */
        
        let data = Data([128, 8, 0, 0, 16, 0, 0, 0, 0, 0, 0, 0, 23, 61, 0, 0, 1, 2, 0, 0, 12, 0, 2, 0, 110, 108, 56, 48, 50, 49, 49, 0, 6, 0, 1, 0, 28, 0, 0, 0, 8, 0, 3, 0, 1, 0, 0, 0, 8, 0, 4, 0, 0, 0, 0, 0, 8, 0, 5, 0, 3, 1, 0, 0, 172, 7, 6, 0, 20, 0, 1, 0, 8, 0, 1, 0, 1, 0, 0, 0, 8, 0, 2, 0, 14, 0, 0, 0, 20, 0, 2, 0, 8, 0, 1, 0, 2, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 3, 0, 8, 0, 1, 0, 5, 0, 0, 0, 8, 0, 2, 0, 14, 0, 0, 0, 20, 0, 4, 0, 8, 0, 1, 0, 6, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 5, 0, 8, 0, 1, 0, 7, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 6, 0, 8, 0, 1, 0, 8, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 7, 0, 8, 0, 1, 0, 9, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 8, 0, 8, 0, 1, 0, 10, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 9, 0, 8, 0, 1, 0, 11, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 10, 0, 8, 0, 1, 0, 12, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 11, 0, 8, 0, 1, 0, 14, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 12, 0, 8, 0, 1, 0, 15, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 13, 0, 8, 0, 1, 0, 16, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 14, 0, 8, 0, 1, 0, 17, 0, 0, 0, 8, 0, 2, 0, 14, 0, 0, 0, 20, 0, 15, 0, 8, 0, 1, 0, 18, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 16, 0, 8, 0, 1, 0, 19, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 17, 0, 8, 0, 1, 0, 20, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 18, 0, 8, 0, 1, 0, 21, 0, 0, 0, 8, 0, 2, 0, 30, 0, 0, 0, 20, 0, 19, 0, 8, 0, 1, 0, 107, 0, 0, 0, 8, 0, 2, 0, 30, 0, 0, 0, 20, 0, 20, 0, 8, 0, 1, 0, 22, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 21, 0, 8, 0, 1, 0, 23, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 22, 0, 8, 0, 1, 0, 24, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 23, 0, 8, 0, 1, 0, 25, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 24, 0, 8, 0, 1, 0, 31, 0, 0, 0, 8, 0, 2, 0, 14, 0, 0, 0, 20, 0, 25, 0, 8, 0, 1, 0, 26, 0, 0, 0, 8, 0, 2, 0, 11, 0, 0, 0, 20, 0, 26, 0, 8, 0, 1, 0, 27, 0, 0, 0, 8, 0, 2, 0, 11, 0, 0, 0, 20, 0, 27, 0, 8, 0, 1, 0, 126, 0, 0, 0, 8, 0, 2, 0, 11, 0, 0, 0, 20, 0, 28, 0, 8, 0, 1, 0, 28, 0, 0, 0, 8, 0, 2, 0, 10, 0, 0, 0, 20, 0, 29, 0, 8, 0, 1, 0, 29, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 30, 0, 8, 0, 1, 0, 33, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 31, 0, 8, 0, 1, 0, 114, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 32, 0, 8, 0, 1, 0, 32, 0, 0, 0, 8, 0, 2, 0, 12, 0, 0, 0, 20, 0, 33, 0, 8, 0, 1, 0, 75, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 34, 0, 8, 0, 1, 0, 76, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 35, 0, 8, 0, 1, 0, 37, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 36, 0, 8, 0, 1, 0, 38, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 37, 0, 8, 0, 1, 0, 39, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 38, 0, 8, 0, 1, 0, 40, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 39, 0, 8, 0, 1, 0, 43, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 40, 0, 8, 0, 1, 0, 44, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 41, 0, 8, 0, 1, 0, 46, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 42, 0, 8, 0, 1, 0, 122, 0, 0, 0, 8, 0, 2, 0, 11, 0, 0, 0, 20, 0, 43, 0, 8, 0, 1, 0, 48, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 44, 0, 8, 0, 1, 0, 49, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 45, 0, 8, 0, 1, 0, 50, 0, 0, 0, 8, 0, 2, 0, 12, 0, 0, 0, 20, 0, 46, 0, 8, 0, 1, 0, 52, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 47, 0, 8, 0, 1, 0, 53, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 48, 0, 8, 0, 1, 0, 54, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 49, 0, 8, 0, 1, 0, 55, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 50, 0, 8, 0, 1, 0, 56, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 51, 0, 8, 0, 1, 0, 57, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 52, 0, 8, 0, 1, 0, 58, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 53, 0, 8, 0, 1, 0, 59, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 54, 0, 8, 0, 1, 0, 67, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 55, 0, 8, 0, 1, 0, 61, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 56, 0, 8, 0, 1, 0, 62, 0, 0, 0, 8, 0, 2, 0, 10, 0, 0, 0, 20, 0, 57, 0, 8, 0, 1, 0, 63, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 58, 0, 8, 0, 1, 0, 65, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 59, 0, 8, 0, 1, 0, 66, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 60, 0, 8, 0, 1, 0, 68, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 61, 0, 8, 0, 1, 0, 69, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 62, 0, 8, 0, 1, 0, 108, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 63, 0, 8, 0, 1, 0, 109, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 64, 0, 8, 0, 1, 0, 73, 0, 0, 0, 8, 0, 2, 0, 10, 0, 0, 0, 20, 0, 65, 0, 8, 0, 1, 0, 74, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 66, 0, 8, 0, 1, 0, 79, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 67, 0, 8, 0, 1, 0, 82, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 68, 0, 8, 0, 1, 0, 81, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 69, 0, 8, 0, 1, 0, 83, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 70, 0, 8, 0, 1, 0, 84, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 71, 0, 8, 0, 1, 0, 85, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 72, 0, 8, 0, 1, 0, 87, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 73, 0, 8, 0, 1, 0, 89, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 74, 0, 8, 0, 1, 0, 90, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 75, 0, 8, 0, 1, 0, 115, 0, 0, 0, 8, 0, 2, 0, 11, 0, 0, 0, 20, 0, 76, 0, 8, 0, 1, 0, 116, 0, 0, 0, 8, 0, 2, 0, 11, 0, 0, 0, 20, 0, 77, 0, 8, 0, 1, 0, 117, 0, 0, 0, 8, 0, 2, 0, 11, 0, 0, 0, 20, 0, 78, 0, 8, 0, 1, 0, 118, 0, 0, 0, 8, 0, 2, 0, 11, 0, 0, 0, 20, 0, 79, 0, 8, 0, 1, 0, 119, 0, 0, 0, 8, 0, 2, 0, 11, 0, 0, 0, 20, 0, 80, 0, 8, 0, 1, 0, 92, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 81, 0, 8, 0, 1, 0, 93, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 82, 0, 8, 0, 1, 0, 94, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 83, 0, 8, 0, 1, 0, 95, 0, 0, 0, 8, 0, 2, 0, 10, 0, 0, 0, 20, 0, 84, 0, 8, 0, 1, 0, 96, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 85, 0, 8, 0, 1, 0, 98, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 86, 0, 8, 0, 1, 0, 99, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 87, 0, 8, 0, 1, 0, 100, 0, 0, 0, 8, 0, 2, 0, 10, 0, 0, 0, 20, 0, 88, 0, 8, 0, 1, 0, 101, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 89, 0, 8, 0, 1, 0, 102, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 90, 0, 8, 0, 1, 0, 103, 0, 0, 0, 8, 0, 2, 0, 30, 0, 0, 0, 20, 0, 91, 0, 8, 0, 1, 0, 104, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 92, 0, 8, 0, 1, 0, 105, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 93, 0, 8, 0, 1, 0, 106, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 94, 0, 8, 0, 1, 0, 111, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 95, 0, 8, 0, 1, 0, 112, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 96, 0, 8, 0, 1, 0, 121, 0, 0, 0, 8, 0, 2, 0, 26, 0, 0, 0, 20, 0, 97, 0, 8, 0, 1, 0, 123, 0, 0, 0, 8, 0, 2, 0, 10, 0, 0, 0, 20, 0, 98, 0, 8, 0, 1, 0, 124, 0, 0, 0, 8, 0, 2, 0, 10, 0, 0, 0, 148, 0, 7, 0, 24, 0, 1, 0, 8, 0, 2, 0, 4, 0, 0, 0, 11, 0, 1, 0, 99, 111, 110, 102, 105, 103, 0, 0, 24, 0, 2, 0, 8, 0, 2, 0, 5, 0, 0, 0, 9, 0, 1, 0, 115, 99, 97, 110, 0, 0, 0, 0, 28, 0, 3, 0, 8, 0, 2, 0, 6, 0, 0, 0, 15, 0, 1, 0, 114, 101, 103, 117, 108, 97, 116, 111, 114, 121, 0, 0, 24, 0, 4, 0, 8, 0, 2, 0, 7, 0, 0, 0, 9, 0, 1, 0, 109, 108, 109, 101, 0, 0, 0, 0, 24, 0, 5, 0, 8, 0, 2, 0, 8, 0, 0, 0, 11, 0, 1, 0, 118, 101, 110, 100, 111, 114, 0, 0, 20, 0, 6, 0, 8, 0, 2, 0, 9, 0, 0, 0, 8, 0, 1, 0, 110, 97, 110, 0])
        
        // parse response
        guard let messages = try? NetlinkGenericMessage.from(data: data),
            let response = messages.first,
            let attributes = try? NetlinkAttributeDecoder().decode(response),
            let identifierAttribute = attributes.first(where: { $0.type == NetlinkAttributeType.Generic.Controller.familyIdentifier }),
            let identifier = UInt16(attributeData: identifierAttribute.payload),
            let nameAttribute = attributes.first(where: { $0.type == NetlinkAttributeType.Generic.Controller.familyName }),
            let nameRawValue = String(attributeData: nameAttribute.payload),
            let versionAttribute = attributes.first(where: { $0.type == NetlinkAttributeType.Generic.Controller.version }),
            let version = UInt32(attributeData: versionAttribute.payload),
            let headerSizeAttribute = attributes.first(where: { $0.type == NetlinkAttributeType.Generic.Controller.headerSize }),
            let headerSize = UInt32(attributeData: headerSizeAttribute.payload),
            let maxAttributesAttribute = attributes.first(where: { $0.type == NetlinkAttributeType.Generic.Controller.maxAttributes }),
            let maxAttributes = UInt32(attributeData: maxAttributesAttribute.payload),
            let operationsAttribute = attributes.first(where: { $0.type == NetlinkAttributeType.Generic.Controller.operations }),
            let operationsArrayAttributes = try? NetlinkAttributeDecoder().decode(operationsAttribute.payload)
            else { XCTFail("Could not parse"); return }
        
        let name = NetlinkGenericFamilyName(rawValue: nameRawValue)
        
        // validate attribute values
        XCTAssertEqual(response.command, .newFamily)
        XCTAssertEqual(identifier, 28)
        XCTAssertEqual(name, .nl80211)
        XCTAssertEqual(version, 1)
        XCTAssertEqual(headerSize, 0)
        XCTAssertEqual(maxAttributes, 259)
        XCTAssertEqual(operationsArrayAttributes.count, 98)
        //XCTAssert(operationsAttribute.type.contains(.nested))
        
        // decode
        do {
            
            var decoder = NetlinkAttributeDecoder()
            decoder.log = { print("Decoder:", $0) }
            let value = try decoder.decode(NetlinkGenericFamilyController.self, from: response)
            
            XCTAssertEqual(value.name, .nl80211)
            XCTAssertEqual(value.identifier.rawValue, 28)
        }
            
        catch { XCTFail("Could not decode: \(error)"); return }
    }
    
    func testGetScanResultsCommand() {
        
        do {
            
            /**
             Waiting for scan to complete...
             Got 33.
             Got NL80211_CMD_NEW_SCAN_RESULTS.
             Scan is done.
             NL80211_CMD_GET_SCAN sent 28 bytes to the kernel.
             
             [0x1C, 0x00, 0x00, 0x00, 0x1C, 0x00, 0x05, 0x03, 0xE2, 0x72, 0x5E, 0x5B, 0x10, 0x19, 0xC0, 0xDC, 0x20, 0x00, 0x00, 0x00, 0x08, 0x00, 0x03, 0x00, 0x06, 0x00, 0x00, 0x00]
             */
            
            let data = Data([0x1C, 0x00, 0x00, 0x00, 0x1C, 0x00, 0x05, 0x03, 0xE2, 0x72, 0x5E, 0x5B, 0x10, 0x19, 0xC0, 0xDC, 0x20, 0x00, 0x00, 0x00, 0x08, 0x00, 0x03, 0x00, 0x06, 0x00, 0x00, 0x00])
            
            var decoder = NetlinkAttributeDecoder()
            decoder.log = { print("Decoder:", $0) }
            
            guard let message = NetlinkGenericMessage(data: data),
                let attributes = try? decoder.decode(message)
                else { XCTFail("Could not parse message from data"); return }
            
            XCTAssertEqual(message.data, data)
            XCTAssertEqual(message.length, 28)
            XCTAssertEqual(Int(message.length), data.count)
            XCTAssertEqual(message.type.rawValue, 28) // NetlinkGenericFamilyIdentifier(rawValue: 28)
            XCTAssertEqual(message.command.rawValue, NetlinkGenericCommand.NL80211.getScan.rawValue)
            XCTAssertEqual(message.version.rawValue, 0)
            XCTAssertEqual(message.flags, 773)
            XCTAssertEqual(attributes.count, 1)
            
            //attributes.forEach { print(NL80211AttributeType(rawValue: $0.type.rawValue)!, Array($0.payload)) }
            
            do {
                
                let command = try decoder.decode(NL80211GetScanResultsCommand.self, from: message)
                XCTAssertEqual(command.interface, 6)
            }
                
            catch { XCTFail("Could not decode: \(error)"); return }
        }
        
        /**
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
            else { XCTFail("Could not parse message from data"); return }
        
        XCTAssertEqual(message.data, data)
        XCTAssertEqual(message.length, 28)
        XCTAssertEqual(Int(message.length), data.count)
        XCTAssertEqual(message.type.rawValue, 28) // NetlinkGenericFamilyIdentifier(rawValue: 28)
        XCTAssertEqual(message.command.rawValue, NetlinkGenericCommand.NL80211.getScan.rawValue)
        XCTAssertEqual(message.version.rawValue, 0)
        XCTAssertEqual(message.flags, [.dump, .request])
        XCTAssertEqual(message.sequence, 0)
        
        do {
            
            var decoder = NetlinkAttributeDecoder()
            decoder.log = { print("Decoder:", $0) }
            let command = try decoder.decode(NL80211GetScanResultsCommand.self, from: message)
            
            XCTAssertEqual(command.interface, 3)
        }
        
        catch { XCTFail("Could not decode: \(error)"); return }
                
        var attributes = [NetlinkAttribute]()
        XCTAssertNoThrow(attributes = try NetlinkAttributeDecoder().decode(message))
        
        guard attributes.count == 1
            else { XCTFail(); return }
        
        XCTAssertEqual(UInt32(attributeData: attributes[0].payload), 3)
        XCTAssertEqual(attributes[0].payload, Data([0x03, 0x00, 0x00, 0x00]))
        XCTAssertEqual(attributes[0].type.rawValue, NetlinkAttributeType.NL80211.interfaceIndex.rawValue)
        
        // libnl message
        XCTAssertEqual(NetlinkGenericMessage(data: Data([28, 0, 0, 0, 28, 0, 5, 5, 96, 138, 91, 91, 237, 32, 0, 92, 32, 0, 0, 0, 8, 0, 3, 0, 3, 0, 0, 0]))?.flags, [.dump, .acknowledgment, .request])
    }
    
    func testTriggerScanResponse() {
        
        /**
         WIPHY [1, 0, 0, 0]
         IFINDEX [4, 0, 0, 0]
         WDEV [1, 0, 0, 0, 1, 0, 0, 0]
         SCAN_SSIDS []
         SCAN_FREQUENCIES [8, 0, 0, 0, 108, 9, 0, 0, 8, 0, 1, 0, 113, 9, 0, 0, 8, 0, 2, 0, 118, 9, 0, 0, 8, 0, 3, 0, 123, 9, 0, 0, 8, 0, 4, 0, 128, 9, 0, 0, 8, 0, 5, 0, 133, 9, 0, 0, 8, 0, 6, 0, 138, 9, 0, 0, 8, 0, 7, 0, 143, 9, 0, 0, 8, 0, 8, 0, 148, 9, 0, 0, 8, 0, 9, 0, 153, 9, 0, 0, 8, 0, 10, 0, 158, 9, 0, 0, 8, 0, 11, 0, 163, 9, 0, 0, 8, 0, 12, 0, 168, 9, 0, 0]
         */
        
        let data = Data([160, 0, 0, 0, 28, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 33, 1, 0, 0, 8, 0, 1, 0, 1, 0, 0, 0, 8, 0, 3, 0, 4, 0, 0, 0, 12, 0, 153, 0, 1, 0, 0, 0, 1, 0, 0, 0, 4, 0, 45, 0, 108, 0, 44, 0, 8, 0, 0, 0, 108, 9, 0, 0, 8, 0, 1, 0, 113, 9, 0, 0, 8, 0, 2, 0, 118, 9, 0, 0, 8, 0, 3, 0, 123, 9, 0, 0, 8, 0, 4, 0, 128, 9, 0, 0, 8, 0, 5, 0, 133, 9, 0, 0, 8, 0, 6, 0, 138, 9, 0, 0, 8, 0, 7, 0, 143, 9, 0, 0, 8, 0, 8, 0, 148, 9, 0, 0, 8, 0, 9, 0, 153, 9, 0, 0, 8, 0, 10, 0, 158, 9, 0, 0, 8, 0, 11, 0, 163, 9, 0, 0, 8, 0, 12, 0, 168, 9, 0, 0])
        
        var decoder = NetlinkAttributeDecoder()
        decoder.log = { print("Decoder:", $0) }
        
        // parse response
        guard let messages = try? NetlinkGenericMessage.from(data: data),
            let message = messages.first,
            let attributes = try? decoder.decode(message),
            let wiphyAttribute = attributes.first(where: { $0.type == NetlinkAttributeType.NL80211.wiphy }),
            let wiphy = UInt32(attributeData: wiphyAttribute.payload),
            let interfaceAttribute = attributes.first(where: { $0.type == NetlinkAttributeType.NL80211.interfaceIndex }),
            let interface = UInt32(attributeData: interfaceAttribute.payload)
            else { XCTFail("Could not parse message from data"); return }
        
        XCTAssertEqual(message.data, data)
        XCTAssertEqual(message.length, 160)
        XCTAssertEqual(Int(message.length), data.count)
        XCTAssertEqual(message.type.rawValue, 28) // driver ID
        XCTAssertEqual(message.command.rawValue, NetlinkGenericCommand.NL80211.triggerScan.rawValue)
        XCTAssertEqual(message.version.rawValue, 1)
        XCTAssertEqual(message.flags, 0)
        XCTAssertEqual(message.sequence, 0)
        
        XCTAssertEqual(wiphy, 1)
        XCTAssertEqual(interface, 4)
        
        do {
            let value = try decoder.decode(NL80211TriggerScanStatus.self, from: message)
            
            XCTAssertEqual(value.wiphy, 1)
            XCTAssertEqual(value.interface, 4)
        }
            
        catch { XCTFail("Could not decode: \(error)"); return }
    }
    
    func testNewScanResults() {
        
        /**
         Interface: wlx74da3826382c
         Wireless Extension Version: 0
         Wireless Extension Name: IEEE 802.11
         Interface: 8
         Trigger scan:
         */
        
        let data = Data([160, 0, 0, 0, 28, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 34, 1, 0, 0, 8, 0, 1, 0, 4, 0, 0, 0, 8, 0, 3, 0, 8, 0, 0, 0, 12, 0, 153, 0, 1, 0, 0, 0, 4, 0, 0, 0, 4, 0, 45, 0, 108, 0, 44, 0, 8, 0, 0, 0, 108, 9, 0, 0, 8, 0, 1, 0, 113, 9, 0, 0, 8, 0, 2, 0, 118, 9, 0, 0, 8, 0, 3, 0, 123, 9, 0, 0, 8, 0, 4, 0, 128, 9, 0, 0, 8, 0, 5, 0, 133, 9, 0, 0, 8, 0, 6, 0, 138, 9, 0, 0, 8, 0, 7, 0, 143, 9, 0, 0, 8, 0, 8, 0, 148, 9, 0, 0, 8, 0, 9, 0, 153, 9, 0, 0, 8, 0, 10, 0, 158, 9, 0, 0, 8, 0, 11, 0, 163, 9, 0, 0, 8, 0, 12, 0, 168, 9, 0, 0]
        )
        
        var decoder = NetlinkAttributeDecoder()
        decoder.log = { print("Decoder:", $0) }
        
        // parse response
        guard let messages = try? NetlinkGenericMessage.from(data: data),
            let message = messages.first,
            let attributes = try? decoder.decode(message),
            let wiphyAttribute = attributes.first(where: { $0.type == NetlinkAttributeType.NL80211.wiphy }),
            let wiphy = UInt32(attributeData: wiphyAttribute.payload),
            let interfaceAttribute = attributes.first(where: { $0.type == NetlinkAttributeType.NL80211.interfaceIndex }),
            let interface = UInt32(attributeData: interfaceAttribute.payload)
            else { XCTFail("Could not parse message from data"); return }
        
        XCTAssertEqual(message.data, data)
        XCTAssertEqual(message.length, 160)
        XCTAssertEqual(Int(message.length), data.count)
        XCTAssertEqual(message.type.rawValue, 28) // driver ID
        XCTAssertEqual(message.command.rawValue, NetlinkGenericCommand.NL80211.newScanResults.rawValue)
        XCTAssertEqual(message.version.rawValue, 1)
        XCTAssertEqual(message.flags, 0)
        XCTAssertEqual(message.sequence, 0)
        
        XCTAssertEqual(wiphy, 4)
        XCTAssertEqual(interface, 8)
        
        do {
            let value = try decoder.decode(NL80211TriggerScanStatus.self, from: message)
            
            XCTAssertEqual(value.wiphy, 4)
            XCTAssertEqual(value.interface, 8)
        }
            
        catch { XCTFail("Could not decode: \(error)"); return }
    }
    
    func testScanData() {
        
        /**
         NL80211_CMD_TRIGGER_SCAN sent 36 bytes to the kernel.
         Waiting for scan to complete...
         Got 33.
         Got NL80211_CMD_NEW_SCAN_RESULTS.
         Scan is done.
         NL80211_CMD_GET_SCAN sent 28 bytes to the kernel.
         callback_dump
         0x58, 0x01, 0x00, 0x00, 0x1C, 0x00, 0x02, 0x00, 0xB1, 0x5B, 0x5E, 0x5B, 0x2F, 0x4E, 0x00, 0xC1, 0x22, 0x01, 0x00, 0x00, 0x08, 0x00, 0x2E, 0x00, 0xCA, 0x05, 0x00, 0x00, 0x08, 0x00, 0x03, 0x00, 0x05, 0x00, 0x00, 0x00, 0x0C, 0x00, 0x99, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x28, 0x01, 0x2F, 0x00, 0x0A, 0x00, 0x01, 0x00, 0x18, 0xA6, 0xF7, 0x99, 0x81, 0x90, 0x00, 0x00, 0x04, 0x00, 0x0E, 0x00, 0x0C, 0x00, 0x03, 0x00, 0x05, 0xD2, 0x98, 0x43, 0x00, 0x00, 0x00, 0x00, 0x61, 0x00, 0x06, 0x00, 0x00, 0x0A, 0x43, 0x4F, 0x4C, 0x45, 0x4D, 0x41, 0x4E, 0x43, 0x44, 0x41, 0x01, 0x08, 0x82, 0x84, 0x8B, 0x96, 0x0C, 0x12, 0x18, 0x24, 0x03, 0x01, 0x02, 0x2A, 0x01, 0x00, 0x30, 0x14, 0x01, 0x00, 0x00, 0x0F, 0xAC, 0x02, 0x01, 0x00, 0x00, 0x0F, 0xAC, 0x02, 0x01, 0x00, 0x00, 0x0F, 0xAC, 0x02, 0x00, 0x00, 0x32, 0x04, 0x30, 0x48, 0x60, 0x6C, 0xDD, 0x18, 0x00, 0x50, 0xF2, 0x02, 0x01, 0x01, 0x80, 0x00, 0x03, 0xA4, 0x00, 0x00, 0x27, 0xA4, 0x00, 0x00, 0x42, 0x43, 0x5E, 0x00, 0x62, 0x32, 0x2F, 0x00, 0xDD, 0x09, 0x00, 0x03, 0x7F, 0x01, 0x01, 0x00, 0x00, 0xFF, 0x7F, 0x00, 0x00, 0x00, 0x0C, 0x00, 0x0D, 0x00, 0x80, 0xB1, 0x98, 0x43, 0x00, 0x00, 0x00, 0x00, 0x67, 0x00, 0x0B, 0x00, 0x00, 0x0A, 0x43, 0x4F, 0x4C, 0x45, 0x4D, 0x41, 0x4E, 0x43, 0x44, 0x41, 0x01, 0x08, 0x82, 0x84, 0x8B, 0x96, 0x0C, 0x12, 0x18, 0x24, 0x03, 0x01, 0x02, 0x05, 0x04, 0x00, 0x01, 0x00, 0x80, 0x2A, 0x01, 0x00, 0x30, 0x14, 0x01, 0x00, 0x00, 0x0F, 0xAC, 0x02, 0x01, 0x00, 0x00, 0x0F, 0xAC, 0x02, 0x01, 0x00, 0x00, 0x0F, 0xAC, 0x02, 0x00, 0x00, 0x32, 0x04, 0x30, 0x48, 0x60, 0x6C, 0xDD, 0x18, 0x00, 0x50, 0xF2, 0x02, 0x01, 0x01, 0x80, 0x00, 0x03, 0xA4, 0x00, 0x00, 0x27, 0xA4, 0x00, 0x00, 0x42, 0x43, 0x5E, 0x00, 0x62, 0x32, 0x2F, 0x00, 0xDD, 0x09, 0x00, 0x03, 0x7F, 0x01, 0x01, 0x00, 0x00, 0xFF, 0x7F, 0x00, 0x06, 0x00, 0x04, 0x00, 0x64, 0x00, 0x00, 0x00, 0x06, 0x00, 0x05, 0x00, 0x31, 0x04, 0x00, 0x00, 0x08, 0x00, 0x02, 0x00, 0x71, 0x09, 0x00, 0x00, 0x08, 0x00, 0x0C, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x0A, 0x00, 0x70, 0x03, 0x00, 0x00, 0x08, 0x00, 0x07, 0x00, 0xD0, 0xEE, 0xFF, 0xFF,
         18:a6:f7:99:81:90, 2417 MHz, COLEMANCDA
         callback_dump
         0x34, 0x02, 0x00, 0x00, 0x1C, 0x00, 0x02, 0x00, 0xB1, 0x5B, 0x5E, 0x5B, 0x2F, 0x4E, 0x00, 0xC1, 0x22, 0x01, 0x00, 0x00, 0x08, 0x00, 0x2E, 0x00, 0xCA, 0x05, 0x00, 0x00, 0x08, 0x00, 0x03, 0x00, 0x05, 0x00, 0x00, 0x00, 0x0C, 0x00, 0x99, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x04, 0x02, 0x2F, 0x00, 0x0A, 0x00, 0x01, 0x00, 0x7A, 0xE2, 0x8F, 0x7C, 0x0B, 0xB2, 0x00, 0x00, 0x04, 0x00, 0x0E, 0x00, 0x0C, 0x00, 0x03, 0x00, 0xCC, 0x48, 0x4C, 0x4C, 0x00, 0x00, 0x00, 0x00, 0xCF, 0x00, 0x06, 0x00, 0x00, 0x1F, 0x41, 0x6C, 0x73, 0x65, 0x79, 0x20, 0x43, 0x6F, 0x6C, 0x65, 0x6D, 0x61, 0x6E, 0x20, 0x4D, 0x69, 0x6C, 0x6C, 0x65, 0x72, 0xE2, 0x80, 0x99, 0x73, 0x20, 0x69, 0x50, 0x68, 0x6F, 0x6E, 0x65, 0x01, 0x08, 0x82, 0x84, 0x8B, 0x96, 0x24, 0x30, 0x48, 0x6C, 0x03, 0x01, 0x06, 0x20, 0x01, 0x00, 0x23, 0x02, 0x11, 0x00, 0x2A, 0x01, 0x04, 0x32, 0x04, 0x0C, 0x12, 0x18, 0x60, 0x30, 0x14, 0x01, 0x00, 0x00, 0x0F, 0xAC, 0x04, 0x01, 0x00, 0x00, 0x0F, 0xAC, 0x04, 0x01, 0x00, 0x00, 0x0F, 0xAC, 0x02, 0x0C, 0x00, 0x2D, 0x1A, 0x21, 0x00, 0x17, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3D, 0x16, 0x06, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x7F, 0x01, 0x04, 0xDD, 0x0A, 0x00, 0x17, 0xF2, 0x06, 0x01, 0x01, 0x03, 0x01, 0x00, 0x00, 0xDD, 0x0D, 0x00, 0x17, 0xF2, 0x06, 0x02, 0x01, 0x06, 0x58, 0xE2, 0x8F, 0x7C, 0x0B, 0xB3, 0xDD, 0x09, 0x00, 0x10, 0x18, 0x02, 0x01, 0x00, 0x1C, 0x00, 0x00, 0xDD, 0x18, 0x00, 0x50, 0xF2, 0x02, 0x01, 0x01, 0x80, 0x00, 0x03, 0xA4, 0x00, 0x00, 0x27, 0xA4, 0x00, 0x00, 0x42, 0x43, 0x5E, 0x00, 0x62, 0x32, 0x2F, 0x00, 0x00, 0x0C, 0x00, 0x0D, 0x00, 0x89, 0x41, 0x4B, 0x4C, 0x00, 0x00, 0x00, 0x00, 0xD5, 0x00, 0x0B, 0x00, 0x00, 0x1F, 0x41, 0x6C, 0x73, 0x65, 0x79, 0x20, 0x43, 0x6F, 0x6C, 0x65, 0x6D, 0x61, 0x6E, 0x20, 0x4D, 0x69, 0x6C, 0x6C, 0x65, 0x72, 0xE2, 0x80, 0x99, 0x73, 0x20, 0x69, 0x50, 0x68, 0x6F, 0x6E, 0x65, 0x01, 0x08, 0x82, 0x84, 0x8B, 0x96, 0x24, 0x30, 0x48, 0x6C, 0x03, 0x01, 0x06, 0x05, 0x04, 0x01, 0x03, 0x00, 0x00, 0x20, 0x01, 0x00, 0x23, 0x02, 0x11, 0x00, 0x2A, 0x01, 0x04, 0x32, 0x04, 0x0C, 0x12, 0x18, 0x60, 0x30, 0x14, 0x01, 0x00, 0x00, 0x0F, 0xAC, 0x04, 0x01, 0x00, 0x00, 0x0F, 0xAC, 0x04, 0x01, 0x00, 0x00, 0x0F, 0xAC, 0x02, 0x0C, 0x00, 0x2D, 0x1A, 0x21, 0x00, 0x17, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3D, 0x16, 0x06, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x7F, 0x01, 0x04, 0xDD, 0x0A, 0x00, 0x17, 0xF2, 0x06, 0x01, 0x01, 0x03, 0x01, 0x00, 0x00, 0xDD, 0x0D, 0x00, 0x17, 0xF2, 0x06, 0x02, 0x01, 0x06, 0x58, 0xE2, 0x8F, 0x7C, 0x0B, 0xB3, 0xDD, 0x09, 0x00, 0x10, 0x18, 0x02, 0x01, 0x00, 0x1C, 0x00, 0x00, 0xDD, 0x18, 0x00, 0x50, 0xF2, 0x02, 0x01, 0x01, 0x80, 0x00, 0x03, 0xA4, 0x00, 0x00, 0x27, 0xA4, 0x00, 0x00, 0x42, 0x43, 0x5E, 0x00, 0x62, 0x32, 0x2F, 0x00, 0x00, 0x00, 0x00, 0x06, 0x00, 0x04, 0x00, 0x64, 0x00, 0x00, 0x00, 0x06, 0x00, 0x05, 0x00, 0x11, 0x15, 0x00, 0x00, 0x08, 0x00, 0x02, 0x00, 0x85, 0x09, 0x00, 0x00, 0x08, 0x00, 0x0C, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x0A, 0x00, 0x94, 0x01, 0x00, 0x00, 0x08, 0x00, 0x07, 0x00, 0x10, 0xF5, 0xFF, 0xFF, 7a:e2:8f:7c:0b:b2, 2437 MHz, Alsey Coleman Miller\xe2\x80\x99s iPhone
         NL80211_CMD_GET_SCAN received 0 bytes from the kernel.
         */
        
        let data = Data([0x58, 0x01, 0x00, 0x00, 0x1C, 0x00, 0x02, 0x00, 0xB1, 0x5B, 0x5E, 0x5B, 0x2F, 0x4E, 0x00, 0xC1, 0x22, 0x01, 0x00, 0x00, 0x08, 0x00, 0x2E, 0x00, 0xCA, 0x05, 0x00, 0x00, 0x08, 0x00, 0x03, 0x00, 0x05, 0x00, 0x00, 0x00, 0x0C, 0x00, 0x99, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x28, 0x01, 0x2F, 0x00, 0x0A, 0x00, 0x01, 0x00, 0x18, 0xA6, 0xF7, 0x99, 0x81, 0x90, 0x00, 0x00, 0x04, 0x00, 0x0E, 0x00, 0x0C, 0x00, 0x03, 0x00, 0x05, 0xD2, 0x98, 0x43, 0x00, 0x00, 0x00, 0x00, 0x61, 0x00, 0x06, 0x00, 0x00, 0x0A, 0x43, 0x4F, 0x4C, 0x45, 0x4D, 0x41, 0x4E, 0x43, 0x44, 0x41, 0x01, 0x08, 0x82, 0x84, 0x8B, 0x96, 0x0C, 0x12, 0x18, 0x24, 0x03, 0x01, 0x02, 0x2A, 0x01, 0x00, 0x30, 0x14, 0x01, 0x00, 0x00, 0x0F, 0xAC, 0x02, 0x01, 0x00, 0x00, 0x0F, 0xAC, 0x02, 0x01, 0x00, 0x00, 0x0F, 0xAC, 0x02, 0x00, 0x00, 0x32, 0x04, 0x30, 0x48, 0x60, 0x6C, 0xDD, 0x18, 0x00, 0x50, 0xF2, 0x02, 0x01, 0x01, 0x80, 0x00, 0x03, 0xA4, 0x00, 0x00, 0x27, 0xA4, 0x00, 0x00, 0x42, 0x43, 0x5E, 0x00, 0x62, 0x32, 0x2F, 0x00, 0xDD, 0x09, 0x00, 0x03, 0x7F, 0x01, 0x01, 0x00, 0x00, 0xFF, 0x7F, 0x00, 0x00, 0x00, 0x0C, 0x00, 0x0D, 0x00, 0x80, 0xB1, 0x98, 0x43, 0x00, 0x00, 0x00, 0x00, 0x67, 0x00, 0x0B, 0x00, 0x00, 0x0A, 0x43, 0x4F, 0x4C, 0x45, 0x4D, 0x41, 0x4E, 0x43, 0x44, 0x41, 0x01, 0x08, 0x82, 0x84, 0x8B, 0x96, 0x0C, 0x12, 0x18, 0x24, 0x03, 0x01, 0x02, 0x05, 0x04, 0x00, 0x01, 0x00, 0x80, 0x2A, 0x01, 0x00, 0x30, 0x14, 0x01, 0x00, 0x00, 0x0F, 0xAC, 0x02, 0x01, 0x00, 0x00, 0x0F, 0xAC, 0x02, 0x01, 0x00, 0x00, 0x0F, 0xAC, 0x02, 0x00, 0x00, 0x32, 0x04, 0x30, 0x48, 0x60, 0x6C, 0xDD, 0x18, 0x00, 0x50, 0xF2, 0x02, 0x01, 0x01, 0x80, 0x00, 0x03, 0xA4, 0x00, 0x00, 0x27, 0xA4, 0x00, 0x00, 0x42, 0x43, 0x5E, 0x00, 0x62, 0x32, 0x2F, 0x00, 0xDD, 0x09, 0x00, 0x03, 0x7F, 0x01, 0x01, 0x00, 0x00, 0xFF, 0x7F, 0x00, 0x06, 0x00, 0x04, 0x00, 0x64, 0x00, 0x00, 0x00, 0x06, 0x00, 0x05, 0x00, 0x31, 0x04, 0x00, 0x00, 0x08, 0x00, 0x02, 0x00, 0x71, 0x09, 0x00, 0x00, 0x08, 0x00, 0x0C, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x0A, 0x00, 0x70, 0x03, 0x00, 0x00, 0x08, 0x00, 0x07, 0x00, 0xD0, 0xEE, 0xFF, 0xFF])
        
        var decoder = NetlinkAttributeDecoder()
        decoder.log = { print("Decoder:", $0) }
        
        // parse response
        guard let message = NetlinkGenericMessage(data: data),
            let attributes = try? decoder.decode(message.payload),
            let interfaceAttribute = attributes.first(where: { $0.type == NetlinkAttributeType.NL80211.interfaceIndex }),
            let interface = UInt32(attributeData: interfaceAttribute.payload)
            else { XCTFail("Could not parse message from data"); return }
        
        XCTAssertEqual(message.data, data)
        XCTAssertEqual(message.length, 344)
        XCTAssertEqual(Int(message.length), data.count)
        XCTAssertEqual(message.type.rawValue, 28) // driver ID
        XCTAssertEqual(message.command.rawValue, NetlinkGenericCommand.NL80211.newScanResults.rawValue)
        XCTAssertEqual(message.version.rawValue, 1)
        XCTAssertEqual(message.flags, 2)
        XCTAssertEqual(message.sequence, 1532910513)
        XCTAssertEqual(interface, 5)
        
        do {
            let value = try decoder.decode(NL80211ScanResult.self, from: message)
            XCTAssertEqual(value.interface, 5)
            XCTAssertEqual(value.generation, 1482)
            XCTAssertEqual(value.wirelessDevice, 0x0100000001)
            XCTAssertEqual(value.bss.bssid.rawValue, "18:A6:F7:99:81:90")
            
            // ssid name
            let ssidLength = min(Int(value.bss.informationElements[1]), 32)
            XCTAssertEqual(String(data: value.bss.informationElements[2 ..< 2 + ssidLength], encoding: .utf8), "COLEMANCDA")
        }
        
        catch { XCTFail("Could not decode: \(error)"); return }
    }
    
    func testErrorMessage() {
        
        do {
            
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
            XCTAssertEqual(error.errorCode, -95)
            
            #if os(Linux)
            XCTAssertEqual(error.error?.code, .EOPNOTSUPP)
            #endif
        }
        
        do {
            
            /**
             Interface: wlx74da3826382c
             Wireless Extension Version: 0
             Wireless Extension Name: IEEE 802.11
             Interface: 6
             Trigger scan:
             [160, 0, 0, 0, 28, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 33, 1, 0, 0, 8, 0, 1, 0, 3, 0, 0, 0, 8, 0, 3, 0, 6, 0, 0, 0, 12, 0, 153, 0, 1, 0, 0, 0, 3, 0, 0, 0, 4, 0, 45, 0, 108, 0, 44, 0, 8, 0, 0, 0, 108, 9, 0, 0, 8, 0, 1, 0, 113, 9, 0, 0, 8, 0, 2, 0, 118, 9, 0, 0, 8, 0, 3, 0, 123, 9, 0, 0, 8, 0, 4, 0, 128, 9, 0, 0, 8, 0, 5, 0, 133, 9, 0, 0, 8, 0, 6, 0, 138, 9, 0, 0, 8, 0, 7, 0, 143, 9, 0, 0, 8, 0, 8, 0, 148, 9, 0, 0, 8, 0, 9, 0, 153, 9, 0, 0, 8, 0, 10, 0, 158, 9, 0, 0, 8, 0, 11, 0, 163, 9, 0, 0, 8, 0, 12, 0, 168, 9, 0, 0]
             Scan results:
             [36, 0, 0, 0, 2, 0, 0, 1, 0, 0, 0, 0, 76, 68, 0, 0, 0, 0, 0, 0, 28, 0, 0, 0, 28, 0, 5, 0, 0, 0, 0, 0, 76, 68, 0, 0]
             Networks:
             */
            
            let data = Data([36, 0, 0, 0, 2, 0, 0, 1, 0, 0, 0, 0, 76, 68, 0, 0, 0, 0, 0, 0, 28, 0, 0, 0, 28, 0, 5, 0, 0, 0, 0, 0, 76, 68, 0, 0])
            
            guard let error = NetlinkErrorMessage(data: data)
                else { XCTFail("Could not parse message"); return }
            
            XCTAssertEqual(error.length, 36)
            XCTAssertEqual(Int(error.length), data.count)
            XCTAssertEqual(error.sequence, 0)
            XCTAssertEqual(error.type, .error)
            XCTAssertEqual(error.errorCode, 0)
        }
    }
}

enum NL80211AttributeType: UInt16 {
    /* don't change the order or add anything between, this is ABI! */
    case UNSPEC
    case WIPHY
    case WIPHY_NAME
    case IFINDEX
    case IFNAME
    case IFTYPE
    case MAC
    case KEY_DATA
    case KEY_IDX
    case KEY_CIPHER
    case KEY_SEQ
    case KEY_DEFAULT
    case BEACON_INTERVAL
    case DTIM_PERIOD
    case BEACON_HEAD
    case BEACON_TAIL
    case STA_AID
    case STA_FLAGS
    case STA_LISTEN_INTERVAL
    case STA_SUPPORTED_RATES
    case STA_VLAN
    case STA_INFO
    case WIPHY_BANDS
    case MNTR_FLAGS
    case MESH_ID
    case STA_PLINK_ACTION
    case MPATH_NEXT_HOP
    case MPATH_INFO
    case BSS_CTS_PROT
    case BSS_SHORT_PREAMBLE
    case BSS_SHORT_SLOT_TIME
    case HT_CAPABILITY
    case SUPPORTED_IFTYPES
    case REG_ALPHA2
    case REG_RULES
    case MESH_CONFIG
    case BSS_BASIC_RATES
    case WIPHY_TXQ_PARAMS
    case WIPHY_FREQ
    case WIPHY_CHANNEL_TYPE
    case KEY_DEFAULT_MGMT
    case MGMT_SUBTYPE
    case IE
    case MAX_NUM_SCAN_SSIDS
    case SCAN_FREQUENCIES
    case SCAN_SSIDS
    case GENERATION /* replaces old SCAN_GENERATION */
    case BSS
    case REG_INITIATOR
    case REG_TYPE
    case SUPPORTED_COMMANDS
    case FRAME
    case SSID
    case AUTH_TYPE
    case REASON_CODE
    case KEY_TYPE
    case MAX_SCAN_IE_LEN
    case CIPHER_SUITES
    case FREQ_BEFORE
    case FREQ_AFTER
    case FREQ_FIXED
    case WIPHY_RETRY_SHORT
    case WIPHY_RETRY_LONG
    case WIPHY_FRAG_THRESHOLD
    case WIPHY_RTS_THRESHOLD
    case TIMED_OUT
    case USE_MFP
    case STA_FLAGS2
    case CONTROL_PORT
    case TESTDATA
    case PRIVACY
    case DISCONNECTED_BY_AP
    case STATUS_CODE
    case CIPHER_SUITES_PAIRWISE
    case CIPHER_SUITE_GROUP
    case WPA_VERSIONS
    case AKM_SUITES
    case REQ_IE
    case RESP_IE
    case PREV_BSSID
    case KEY
    case KEYS
    case PID
    case _4ADDR
    case SURVEY_INFO
    case PMKID
    case MAX_NUM_PMKIDS
    case DURATION
    case COOKIE
    case WIPHY_COVERAGE_CLASS
    case TX_RATES
    case FRAME_MATCH
    case ACK
    case PS_STATE
    case CQM
    case LOCAL_STATE_CHANGE
    case AP_ISOLATE
    case WIPHY_TX_POWER_SETTING
    case WIPHY_TX_POWER_LEVEL
    case TX_FRAME_TYPES
    case RX_FRAME_TYPES
    case FRAME_TYPE
    case CONTROL_PORT_ETHERTYPE
    case CONTROL_PORT_NO_ENCRYPT
    case SUPPORT_IBSS_RSN
    case WIPHY_ANTENNA_TX
    case WIPHY_ANTENNA_RX
    case MCAST_RATE
    case OFFCHANNEL_TX_OK
    case BSS_HT_OPMODE
    case KEY_DEFAULT_TYPES
    case MAX_REMAIN_ON_CHANNEL_DURATION
    case MESH_SETUP
    case WIPHY_ANTENNA_AVAIL_TX
    case WIPHY_ANTENNA_AVAIL_RX
    case SUPPORT_MESH_AUTH
    case STA_PLINK_STATE
    case WOWLAN_TRIGGERS
    case WOWLAN_TRIGGERS_SUPPORTED
    case SCHED_SCAN_INTERVAL
    case INTERFACE_COMBINATIONS
    case SOFTWARE_IFTYPES
    case REKEY_DATA
    case MAX_NUM_SCHED_SCAN_SSIDS
    case MAX_SCHED_SCAN_IE_LEN
    case SCAN_SUPP_RATES
    case HIDDEN_SSID
    case IE_PROBE_RESP
    case IE_ASSOC_RESP
    case STA_WME
    case SUPPORT_AP_UAPSD
    case ROAM_SUPPORT
    case SCHED_SCAN_MATCH
    case MAX_MATCH_SETS
    case PMKSA_CANDIDATE
    case TX_NO_CCK_RATE
    case TDLS_ACTION
    case TDLS_DIALOG_TOKEN
    case TDLS_OPERATION
    case TDLS_SUPPORT
    case TDLS_EXTERNAL_SETUP
    case DEVICE_AP_SME
    case DONT_WAIT_FOR_ACK
    case FEATURE_FLAGS
    case PROBE_RESP_OFFLOAD
    case PROBE_RESP
    case DFS_REGION
    case DISABLE_HT
    case HT_CAPABILITY_MASK
    case NOACK_MAP
    case INACTIVITY_TIMEOUT
    case RX_SIGNAL_DBM
    case BG_SCAN_PERIOD
    case WDEV
    case USER_REG_HINT_TYPE
    case CONN_FAILED_REASON
    case SAE_DATA
    case VHT_CAPABILITY
    case SCAN_FLAGS
    case CHANNEL_WIDTH
    case CENTER_FREQ1
    case CENTER_FREQ2
    case P2P_CTWINDOW
    case P2P_OPPPS
    case LOCAL_MESH_POWER_MODE
    case ACL_POLICY
    case MAC_ADDRS
    case MAC_ACL_MAX
    case RADAR_EVENT
    case EXT_CAPA
    case EXT_CAPA_MASK
    case STA_CAPABILITY
    case STA_EXT_CAPABILITY
    case PROTOCOL_FEATURES
    case SPLIT_WIPHY_DUMP
    case DISABLE_VHT
    case VHT_CAPABILITY_MASK
    case MDID
    case IE_RIC
    case CRIT_PROT_ID
    case MAX_CRIT_PROT_DURATION
    case PEER_AID
    case COALESCE_RULE
    case CH_SWITCH_COUNT
    case CH_SWITCH_BLOCK_TX
    case CSA_IES
    case CSA_C_OFF_BEACON
    case CSA_C_OFF_PRESP
    case RXMGMT_FLAGS
    case STA_SUPPORTED_CHANNELS
    case STA_SUPPORTED_OPER_CLASSES
    case HANDLE_DFS
    case SUPPORT_5_MHZ
    case SUPPORT_10_MHZ
    case OPMODE_NOTIF
    case VENDOR_ID
    case VENDOR_SUBCMD
    case VENDOR_DATA
    case VENDOR_EVENTS
    case QOS_MAP
    case MAC_HINT
    case WIPHY_FREQ_HINT
    case MAX_AP_ASSOC_STA
    case TDLS_PEER_CAPABILITY
    case SOCKET_OWNER
    case CSA_C_OFFSETS_TX
    case MAX_CSA_COUNTERS
    case TDLS_INITIATOR
    case USE_RRM
    case WIPHY_DYN_ACK
    case TSID
    case USER_PRIO
    case ADMITTED_TIME
    case SMPS_MODE
    case OPER_CLASS
    case MAC_MASK
    case WIPHY_SELF_MANAGED_REG
    case EXT_FEATURES
    case SURVEY_RADIO_STATS
    case NETNS_FD
    case SCHED_SCAN_DELAY
    case REG_INDOOR
    case MAX_NUM_SCHED_SCAN_PLANS
    case MAX_SCAN_PLAN_INTERVAL
    case MAX_SCAN_PLAN_ITERATIONS
    case SCHED_SCAN_PLANS
    case PBSS
    case BSS_SELECT
    case STA_SUPPORT_P2P_PS
    case PAD
    case IFTYPE_EXT_CAPA
    case MU_MIMO_GROUP_DATA
    case MU_MIMO_FOLLOW_MAC_ADDR
    case SCAN_START_TIME_TSF
    case SCAN_START_TIME_TSF_BSSID
    case MEASUREMENT_DURATION
    case MEASUREMENT_DURATION_MANDATORY
    case MESH_PEER_AID
}
