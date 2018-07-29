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
            case NetlinkAttributeType.Generic.Controller.familyName:
                self = .name
            default:
                return nil
            }
        }
        
        var attribute: NetlinkAttributeType {
            
            switch self {
            case .name:
                return NetlinkAttributeType.Generic.Controller.familyName
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
