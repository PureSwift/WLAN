//
//  NetlinkGenericGroup.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/7/18.
//

import Foundation

#if swift(>=3.2)
#elseif swift(>=3.0)
    import Codable
#endif

public struct NetlinkGenericGroupName: RawRepresentable {
    
    public let rawValue: String
    
    public init(rawValue: String) {
        
        self.rawValue = rawValue
    }
}

// MARK: - Equatable

extension NetlinkGenericGroupName: Equatable {
    
    public static func == (lhs: NetlinkGenericGroupName, rhs: NetlinkGenericGroupName) -> Bool {
        
        return lhs.rawValue == rhs.rawValue
    }
}

// MARK: - Codable

extension NetlinkGenericGroupName: Codable {
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.singleValueContainer()
        
        let rawValue = try container.decode(String.self)
        
        self.init(rawValue: rawValue)
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.singleValueContainer()
        
        try container.encode(rawValue)
    }
}
