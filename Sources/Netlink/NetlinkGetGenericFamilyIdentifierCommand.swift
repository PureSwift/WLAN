//
//  NetlinkGetGenericFamilyIdentifierCommand.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/28/18.
//

import Foundation
import CLinuxWLAN

#if swift(>=3.2)
#elseif swift(>=3.0)
    import Codable
#endif

public struct NetlinkGetGenericFamilyIdentifierCommand {
    
    public static let command: NetlinkGenericCommand = .getFamily
    
    public static let version: NetlinkGenericVersion = 1
    
    public var name: NetlinkGenericFamilyName
    
    public init(name: NetlinkGenericFamilyName) {
        
        self.name = name
    }
}

extension NetlinkGetGenericFamilyIdentifierCommand: Codable {
    
    internal enum CodingKeys: String, NetlinkAttributeCodingKey {
        
        case name
        
        init?(attribute: NetlinkAttributeType) {
            
            switch attribute {
            case NetlinkAttributeType.Generic.familyName:
                self = .name
            default:
                return nil
            }
        }
        
        var attribute: NetlinkAttributeType {
            
            switch self {
            case .name:
                return NetlinkAttributeType.Generic.familyName
            }
        }
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let name = try container.decode(NetlinkGenericFamilyName.self, forKey: .name)
        
        self.init(name: name)
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name.rawValue, forKey: .name)
    }
}

// MARK: - Request

public extension NetlinkSocket {
    
    /// Query the family name.
    func resolve(name: NetlinkGenericFamilyName) throws -> NetlinkGenericFamilyIdentifier {
        
        guard netlinkProtocol == .generic
            else { throw NetlinkSocketError.invalidProtocol }
        
        //let command = NetlinkGetGenericFamilyIdentifierCommand(name: name)
        
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
        guard let messages = try? NetlinkGenericMessage.from(data: recievedData),
            let response = messages.first,
            let attributes = try? NetlinkAttribute.from(message: response),
            let identifierAttribute = attributes.first(where: { $0.type == NetlinkAttributeType.Generic.familyIdentifier }),
            let identifier = UInt16(attributeData: identifierAttribute.payload)
            else { throw NetlinkSocketError.invalidData(recievedData) }
        
        return NetlinkGenericFamilyIdentifier(rawValue: Int32(identifier))
    }
}
