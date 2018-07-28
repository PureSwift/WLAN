//
//  GenericCommand.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/7/18.
//

import CLinuxWLAN

public struct NetlinkGenericCommand: RawRepresentable {
    
    public let rawValue: UInt8
    
    public init(rawValue: UInt8) {
        
        self.rawValue = rawValue
    }
}

// MARK: - Equatable

extension NetlinkGenericCommand: Equatable {
    
    public static func == (lhs: NetlinkGenericCommand, rhs: NetlinkGenericCommand) -> Bool {
        
        return lhs.rawValue == rhs.rawValue
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension NetlinkGenericCommand: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt8) {
        
        self.init(rawValue: value)
    }
}

// MARK: -

public extension NetlinkGenericCommand {
    
    public static let getFamily = NetlinkGenericCommand(rawValue: UInt8(CTRL_CMD_GETFAMILY))
}
