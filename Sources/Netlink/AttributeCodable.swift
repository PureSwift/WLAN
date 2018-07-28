//
//  AttributeCodable.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/28/18.
//

import Foundation

#if swift(>=3.2)
#elseif swift(>=3.0)
    import Codable
#endif

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
