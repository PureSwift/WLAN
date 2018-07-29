//
//  GenericController.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/28/18.
//

import Foundation

public struct NetlinkGenericFamilyController {
    
    public let identifier: NetlinkGenericFamilyIdentifier
    
    public var name: NetlinkGenericFamilyName
    
    public var version: UInt32
    
    public var headerSize: UInt32
    
    public var maxAttributes: UInt32
    
    public var operations: [Operation]
    
    public var multicastGroups: [MulticastGroup]
}

public extension NetlinkGenericFamilyController {
    
    public struct Operation {
        
        public let identifier: UInt32
        
        public var flags: UInt32
    }
}

public extension NetlinkGenericFamilyController {
    
    public struct MulticastGroup {
        
        public let name: NetlinkGenericFamilyName
        
        public let identifier: UInt32
    }
}

// MARK: - Codable

extension NetlinkGenericFamilyController: Codable {
    
    internal enum CodingKeys: String, NetlinkAttributeCodingKey {
        
        case identifier
        case name
        case version
        case headerSize
        case maxAttributes
        case operations
        case multicastGroups
        
        init?(attribute: NetlinkAttributeType) {
            
            switch attribute {
            case NetlinkAttributeType.Generic.Controller.familyIdentifier:
                self = .identifier
            case NetlinkAttributeType.Generic.Controller.familyName:
                self = .name
            case NetlinkAttributeType.Generic.Controller.version:
                self = .version
            case NetlinkAttributeType.Generic.Controller.headerSize:
                self = .headerSize
            case NetlinkAttributeType.Generic.Controller.maxAttributes:
                self = .maxAttributes
            case NetlinkAttributeType.Generic.Controller.operations:
                self = .operations
            case NetlinkAttributeType.Generic.Controller.multicastGroups:
                self = .multicastGroups
            default:
                return nil
            }
        }
        
        var attribute: NetlinkAttributeType {
            
            switch self {
            case .identifier:
                return NetlinkAttributeType.Generic.Controller.familyIdentifier
            case .name:
                return NetlinkAttributeType.Generic.Controller.familyName
            case .version:
                return NetlinkAttributeType.Generic.Controller.version
            case .headerSize:
                return NetlinkAttributeType.Generic.Controller.headerSize
            case .maxAttributes:
                return NetlinkAttributeType.Generic.Controller.maxAttributes
            case .operations:
                return NetlinkAttributeType.Generic.Controller.operations
            case .multicastGroups:
                return NetlinkAttributeType.Generic.Controller.multicastGroups
            }
        }
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.identifier = try container.decode(NetlinkGenericFamilyIdentifier.self, forKey: .identifier)
        self.name = try container.decode(NetlinkGenericFamilyName.self, forKey: .name)
        self.version = try container.decode(UInt32.self, forKey: .version)
        self.headerSize = try container.decode(UInt32.self, forKey: .headerSize)
        self.maxAttributes = try container.decode(UInt32.self, forKey: .maxAttributes)
        self.operations = try container.decode([Operation].self, forKey: .operations)
        self.multicastGroups = try container.decode([MulticastGroup].self, forKey: .multicastGroups)
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(identifier, forKey: .identifier)
        try container.encode(name, forKey: .name)
        try container.encode(version, forKey: .version)
        try container.encode(headerSize, forKey: .headerSize)
        try container.encode(maxAttributes, forKey: .maxAttributes)
        try container.encode(operations, forKey: .operations)
        try container.encode(multicastGroups, forKey: .multicastGroups)
    }
}

extension NetlinkGenericFamilyController.Operation: Codable {
    
    internal enum CodingKeys: String, NetlinkAttributeCodingKey {
        
        case identifier
        case flags
        
        init?(attribute: NetlinkAttributeType) {
            
            switch attribute {
            case NetlinkAttributeType.Generic.Controller.Operation.identifier:
                self = .identifier
            case NetlinkAttributeType.Generic.Controller.Operation.flags:
                self = .flags
            default:
                return nil
            }
        }
        
        var attribute: NetlinkAttributeType {
            
            switch self {
            case .identifier:
                return NetlinkAttributeType.Generic.Controller.Operation.identifier
            case .flags:
                return NetlinkAttributeType.Generic.Controller.Operation.flags
            }
        }
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.identifier = try container.decode(UInt32.self, forKey: .identifier)
        self.flags = try container.decode(UInt32.self, forKey: .flags)
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(identifier, forKey: .identifier)
        try container.encode(flags, forKey: .flags)
    }
}

extension NetlinkGenericFamilyController.MulticastGroup: Codable {
    
    internal enum CodingKeys: String, NetlinkAttributeCodingKey {
        
        case identifier
        case name
        
        init?(attribute: NetlinkAttributeType) {
            
            switch attribute {
            case NetlinkAttributeType.Generic.Controller.MulticastGroup.identifier:
                self = .identifier
            case NetlinkAttributeType.Generic.Controller.MulticastGroup.name:
                self = .name
            default:
                return nil
            }
        }
        
        var attribute: NetlinkAttributeType {
            
            switch self {
            case .identifier:
                return NetlinkAttributeType.Generic.Controller.MulticastGroup.identifier
            case .name:
                return NetlinkAttributeType.Generic.Controller.MulticastGroup.name
            }
        }
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.identifier = try container.decode(UInt32.self, forKey: .identifier)
        self.name = try container.decode(NetlinkGenericFamilyName.self, forKey: .name)
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name.rawValue, forKey: .name)
    }
}
