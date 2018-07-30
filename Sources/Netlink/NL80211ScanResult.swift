//
//  NL80211ScanResult.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/29/18.
//


import Foundation
import WLAN

#if swift(>=3.2)
#elseif swift(>=3.0)
    import Codable
#endif

public struct NL80211ScanResult {
    
    public static let command = NetlinkGenericCommand.NL80211.newScanResults
    
    public static let version: NetlinkGenericVersion = 0
    
    public let generation: UInt32
    
    public let interface: UInt32
    
    public let wirelessDevice: UInt64
    
    public let bss: BSS
}

public extension NL80211ScanResult {
    
    public struct BSS {
        
        public let bssid: BSSID
    }
}

// MARK: - Codable

extension NL80211ScanResult: Codable {
    
    internal enum CodingKeys: String, NetlinkAttributeCodingKey {
        
        case bss
        case generation
        case interfaceIndex
        case wirelessDevice
        
        init?(attribute: NetlinkAttributeType) {
            
            switch attribute {
            case NetlinkAttributeType.NL80211.bss:
                self = .bss
            case NetlinkAttributeType.NL80211.generation:
                self = .generation
            case NetlinkAttributeType.NL80211.interfaceIndex:
                self = .interfaceIndex
            case NetlinkAttributeType.NL80211.wirelessDevice:
                self = .wirelessDevice
            default:
                return nil
            }
        }
        
        var attribute: NetlinkAttributeType {
            
            switch self {
            case .bss:
                return NetlinkAttributeType.NL80211.bss
            case .generation:
                return NetlinkAttributeType.NL80211.generation
            case .interfaceIndex:
                return NetlinkAttributeType.NL80211.interfaceIndex
            case .wirelessDevice:
                return NetlinkAttributeType.NL80211.wirelessDevice
            }
        }
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.interface = try container.decode(UInt32.self, forKey: .interfaceIndex)
        self.generation = try container.decode(UInt32.self, forKey: .generation)
        self.wirelessDevice = try container.decode(UInt64.self, forKey: .wirelessDevice)
        self.bss = try container.decode(BSS.self, forKey: .bss)
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(bss, forKey: .bss)
        try container.encode(interface, forKey: .interfaceIndex)
        try container.encode(generation, forKey: .generation)
        try container.encode(wirelessDevice, forKey: .wirelessDevice)
    }
}

extension NL80211ScanResult.BSS: Codable {
    
    internal enum CodingKeys: String, NetlinkAttributeCodingKey {
        
        case bssid
        
        init?(attribute: NetlinkAttributeType) {
            
            switch attribute {
            case NetlinkAttributeType.NL80211.BSS.bssid:
                self = .bssid
            default:
                return nil
            }
        }
        
        var attribute: NetlinkAttributeType {
            
            switch self {
            case .bssid:
                return NetlinkAttributeType.NL80211.BSS.bssid
            }
        }
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.bssid = try container.decode(BSSID.self, forKey: .bssid)
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(bssid, forKey: .bssid)
    }
}

extension BSSID: Codable {
    
    public enum DecodingError: Error {
        
        case invalidData(Data)
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.singleValueContainer()
        
        let data = try container.decode(Data.self)
        
        guard let bigEndianValue = BSSID(data: data)
            else { throw DecodingError.invalidData(data) }
        
        self = BSSID(bigEndian: bigEndianValue)
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.singleValueContainer()
        
        // store as big endian representation
        try container.encode(bigEndian.data)
    }
}
