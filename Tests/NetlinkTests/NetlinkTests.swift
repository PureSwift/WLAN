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
        ("testResolveGenericFamilyCommand", testResolveGenericFamilyCommand),
        ("testResolveGenericFamilyResponse", testResolveGenericFamilyResponse),
        ("testGetScanResultsCommand", testGetScanResultsCommand),
        ("testErrorMessage", testErrorMessage)
    ]
    
    func testResolveGenericFamilyCommand() {
        
        /**
         let attribute = NetlinkAttribute(value: name.rawValue, type: NetlinkAttributeType.Generic.familyName)
         
         let message = NetlinkGenericMessage(type: NetlinkMessageType(rawValue: UInt16(GENL_ID_CTRL)),
            flags: .request,
            sequence: 0,
            process: 0, // kernel
            command: .getFamily,
            version: 1,
            payload: attribute.paddedData)
         
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
        XCTAssertEqual(message.type.rawValue, 16)
        XCTAssertEqual(message.command, .getFamily)
        XCTAssertEqual(message.version.rawValue, 1)
        XCTAssertEqual(message.flags.rawValue, 1)
        XCTAssertEqual(message.sequence, 0)
        
        do {
            
            var decoder = NetlinkAttributeDecoder()
            decoder.log = { print("Decoder:", $0) }
            let command = try decoder.decode(NetlinkGetGenericFamilyIdentifierCommand.self, from: message)
            
            XCTAssertEqual(command.name.rawValue, "nl80211")
        }
            
        catch { XCTFail("Could not decode: \(error)"); return }
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
            else { XCTFail("Could not parse message from data"); return }
        
        XCTAssertEqual(message.data, data)
        XCTAssertEqual(message.length, 28)
        XCTAssertEqual(Int(message.length), data.count)
        XCTAssertEqual(message.type.rawValue, 28) // NetlinkGenericFamilyIdentifier(rawValue: 28)
        XCTAssertEqual(message.command.rawValue, NetlinkGenericCommand.NL80211.getScanResults.rawValue)
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
