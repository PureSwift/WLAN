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
        
        init?(attribute: NetlinkAttributeType) {
            
            switch attribute {
            case NetlinkAttributeType.NL80211.bss:
                self = .bss
            default:
                return nil
            }
        }
        
        var attribute: NetlinkAttributeType {
            
            switch self {
            case .bss:
                return NetlinkAttributeType.NL80211.bss
            }
        }
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.bss = try container.decode(BSS.self, forKey: .bss)
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(bss, forKey: .bss)
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
