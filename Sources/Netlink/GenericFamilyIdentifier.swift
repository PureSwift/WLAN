//
//  NetlinkGenericFamilyIdentifier.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/7/18.
//

import Foundation
import CLinuxWLAN

/// Netlink Generic Family Identifier
public struct NetlinkGenericFamilyIdentifier: RawRepresentable {
    
    public let rawValue: Int32
    
    public init(rawValue: Int32) {
        
        self.rawValue = rawValue
    }
}

// MARK: - Static Identifiers

public extension NetlinkGenericFamilyIdentifier {
    
    public static let generate = NetlinkGenericFamilyIdentifier(rawValue: GENL_ID_GENERATE)
    
    public static let control = NetlinkGenericFamilyIdentifier(rawValue: GENL_ID_CTRL)
}

// MARK: - Request

public extension NetlinkSocket {
    
    /// Query the family name.
    func resolve(name: NetlinkGenericFamilyName) throws -> NetlinkGenericFamilyIdentifier {
        
        guard netlinkProtocol == .generic
            else { throw NetlinkSocketError.invalidProtocol }
        
        let attribute = NetlinkAttribute(value: name.rawValue,
                                         type: NetlinkAttributeType.Generic.familyName)
        
        let message = NetlinkGenericMessage(type: NetlinkMessageType(rawValue: UInt16(GENL_ID_CTRL)),
                                            flags: .request,
                                            sequence: 0,
                                            process: 0, // kernel
                                            command: .getFamily,
                                            version: 1,
                                            payload: attribute.paddedData)
        
        // send message to kernel
        try send(message.data)
        let recievedData = try recieve()
        
        // parse response
        guard let response = NetlinkGenericMessage(data: recievedData),
            let attributes = try? NetlinkAttribute.from(message: response),
            let identifierAttribute = attributes.first(where: { $0.type == NetlinkAttributeType.Generic.familyIdentifier }),
                let identifier = UInt16(attribute: identifierAttribute)
            else { throw NetlinkSocketError.invalidData(recievedData) }
        
        return NetlinkGenericFamilyIdentifier(rawValue: Int32(identifier))
    }
}
