//
//  SSID.swift
//  WLAN
//
//  Created by Alsey Coleman Miller on 7/4/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

import Foundation

/**
 Service Set Identifier
 
  An SSID is a unique ID that consists of 32 characters and is used for naming wireless networks. When multiple wireless networks overlap in a certain location, SSIDs make sure that data gets sent to the correct destination.
 */
public struct SSID {
    
    /// Maximum Length
    internal static let length = 32
    
    // MARK: - Properties
    
    public let data: Data
    
    // MARK: - Initialization
    
    public init?(data: Data) {
        
        guard data.count < SSID.length
            else { return nil }
        
        self.data = data
    }
    
    public init?(string: String) {
        
        guard let data = string.data(using: .utf8)
            else { return nil }
        
        self.init(data: data)
    }
}

// MARK: - Equatable

extension SSID: Equatable {
    
    public static func == (lhs: SSID, rhs: SSID) -> Bool {
        
        return lhs.data == rhs.data
    }
}

// MARK: - Hashable

extension SSID: Hashable {
    
    public var hashValue: Int {
        
        return data.hashValue
    }
}

// MARK: - CustomStringConvertible

extension SSID: CustomStringConvertible {
    
    public var description: String {
        
        if let string = String.init(data: self.data, encoding: .utf8) {
            
            return string
            
        } else {
            
            return self.data.description
        }
    }
}

// MARK: - ExpressibleByStringLiteral

extension SSID: ExpressibleByStringLiteral {
    
    public init(stringLiteral string: String) {
        
        // truncate
        self.data = Data(string.utf8.prefix(SSID.length))
    }
}
