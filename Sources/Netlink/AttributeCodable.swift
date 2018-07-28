//
//  AttributeCodable.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/28/18.
//

import Foundation

public enum AttributeValue {
    
    case data(Data) // custom data type
    case string(String)
    case uint16(UInt16)
    case uint32(UInt32)
    case uint64(UInt64)
}
