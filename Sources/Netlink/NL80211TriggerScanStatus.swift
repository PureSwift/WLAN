//
//  NL80211TriggerScanStatus.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/29/18.
//


import Foundation

#if swift(>=3.2)
#elseif swift(>=3.0)
    import Codable
#endif

public struct NL80211TriggerScanStatus {
    
    public static let command = NetlinkGenericCommand.NL80211.triggerScan
    
    public let wiphy: UInt32
    
    public let interface: UInt32
    
    public let wirelessDevice: UInt64
    
    public let scanSSIDs: [String]
    
    public let scanFrequencies: [UInt32]
}

extension NL80211TriggerScanStatus: Codable {
    
    internal enum CodingKeys: String, NetlinkAttributeCodingKey {
        
        case wiphy
        case interfaceIndex
        case wirelessDevice
        case scanSSIDs
        case scanFrequencies
        
        init?(attribute: NetlinkAttributeType) {
            
            switch attribute {
            case NetlinkAttributeType.NL80211.interfaceIndex:
                self = .interfaceIndex
            case NetlinkAttributeType.NL80211.wiphy:
                self = .wiphy
            case NetlinkAttributeType.NL80211.wirelessDevice:
                self = .wirelessDevice
            case NetlinkAttributeType.NL80211.scanSSIDs:
                self = .scanSSIDs
            case NetlinkAttributeType.NL80211.scanFrequencies:
                self = .scanFrequencies
            default:
                return nil
            }
        }
        
        var attribute: NetlinkAttributeType {
            
            switch self {
            case .interfaceIndex:
                return NetlinkAttributeType.NL80211.interfaceIndex
            case .wiphy:
                return NetlinkAttributeType.NL80211.wiphy
            case .wirelessDevice:
                return NetlinkAttributeType.NL80211.wirelessDevice
            case .scanSSIDs:
                return NetlinkAttributeType.NL80211.scanSSIDs
            case .scanFrequencies:
                return NetlinkAttributeType.NL80211.scanFrequencies
            }
        }
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.wiphy = try container.decode(UInt32.self, forKey: .wiphy)
        self.interface = try container.decode(UInt32.self, forKey: .interfaceIndex)
        self.wirelessDevice = try container.decode(UInt64.self, forKey: .wirelessDevice)
        self.scanSSIDs = try container.decode([String].self, forKey: .scanSSIDs)
        self.scanFrequencies = try container.decode([UInt32].self, forKey: .scanFrequencies)
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(wiphy, forKey: .wiphy)
        try container.encode(interface, forKey: .interfaceIndex)
        try container.encode(wirelessDevice, forKey: .wirelessDevice)
        try container.encode(scanSSIDs, forKey: .scanSSIDs)
        try container.encode(scanFrequencies, forKey: .scanFrequencies)
    }
}
