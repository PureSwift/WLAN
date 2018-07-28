//
//  AttributeCodable.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/28/18.
//

import Foundation

public struct NetlinkGetGenericFamilyIdentifier {
    
    public static let command: NetlinkGenericCommand = .getFamily
    
    public static let version: NetlinkGenericVersion = 1
    
    public var name: NetlinkGenericFamilyName
    
    public init(name: NetlinkGenericFamilyName) {
        
        self.name = name
    }
}

extension NetlinkGetGenericFamilyIdentifier: Codable {
    
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
        
        let name = try container.decode(String.self, forKey: .name)
        
        self.init(name: NetlinkGenericFamilyName(rawValue: name))
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name.rawValue, forKey: .name)
    }
}

public struct NL80211GetScanResults {
    
    public static let command = NetlinkGenericCommand.NL80211.getScanResults
    
    
}

public protocol NetlinkAttributeCodingKey: CodingKey {
    
    init?(attribute: NetlinkAttributeType)
    
    var attribute: NetlinkAttributeType { get }
}

public extension NetlinkAttributeCodingKey {
    
    init?(intValue: Int) {
        
        guard intValue <= Int(UInt16.max),
            intValue >= Int(UInt16.min)
            else { return nil }
        
        self.init(attribute: NetlinkAttributeType(rawValue: UInt16(intValue)))
    }
    
    var intValue: Int? {
        
        return Int(attribute.rawValue)
    }
}
