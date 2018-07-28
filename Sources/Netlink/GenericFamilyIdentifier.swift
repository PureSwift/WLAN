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
        
        // nl_put_str(nl, CTRL_ATTR_FAMILY_NAME, name);
        let attribute = NetlinkAttribute(type: NetlinkAttributeType.Generic.familyName, payload: <#T##Data#>)
        
        // nl_new_cmd(nl, GENL_ID_CTRL, CTRL_CMD_GETFAMILY, 1);
        let message = NetlinkGenericMessage(type: NetlinkMessageType(rawValue: UInt16(GENL_ID_CTRL)),
                                            flags: .request,
                                            sequence: 0,
                                            process: 0, // kernel
                                            command: .getFamily,
                                            version: 1,
                                            payload: Data())
        
        
    }
}
