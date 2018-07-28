//
//  GenericGroupIdentifier.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/28/18.
//

import Foundation
import CLinuxWLAN

/// Netlink Generic Family Group Identifier
public struct NetlinkGenericGroupIdentifier: RawRepresentable {
    
    public let rawValue: Int32
    
    public init(rawValue: Int32) {
        
        self.rawValue = rawValue
    }
}


// MARK: - Request

public extension NetlinkSocket {
    
    /// Query the family name.
    func resolveGroup(name: NetlinkGenericFamilyName) throws -> NetlinkGenericFamilyIdentifier {
        
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
