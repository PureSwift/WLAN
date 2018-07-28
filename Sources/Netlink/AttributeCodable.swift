//
//  AttributeCodable.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/28/18.
//

import Foundation

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

internal extension NetlinkAttributeType {
    
    init? <K: CodingKey> (codingKey: K) {
        
        guard let intValue = codingKey.intValue,
            intValue <= Int(UInt16.max),
            intValue >= Int(UInt16.min)
            else { return nil }
        
        self.init(rawValue: UInt16(intValue))
    }
}

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
        
        let name = try container.decode(String.self, forKey: .name)
        
        self.init(name: NetlinkGenericFamilyName(rawValue: name))
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name.rawValue, forKey: .name)
    }
}

public struct NL80211GetScanResultsCommand {
    
    public static let command = NetlinkGenericCommand.NL80211.getScanResults
    
    public static let version: NetlinkGenericVersion = 0
    
    public var interface: UInt32
    
    public init(interface: UInt32) {
        
        self.interface = interface
    }
}

extension NL80211GetScanResultsCommand: Codable {
    
    internal enum CodingKeys: String, NetlinkAttributeCodingKey {
        
        case interfaceIndex
        
        init?(attribute: NetlinkAttributeType) {
            
            switch attribute {
            case NetlinkAttributeType.NL80211.interfaceIndex:
                self = .interfaceIndex
            default:
                return nil
            }
        }
        
        var attribute: NetlinkAttributeType {
            
            switch self {
            case .interfaceIndex:
                return NetlinkAttributeType.NL80211.interfaceIndex
            }
        }
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let interfaceIndex = try container.decode(UInt32.self, forKey: .interfaceIndex)
        
        self.init(interface: interfaceIndex)
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(interface, forKey: .interfaceIndex)
    }
}
