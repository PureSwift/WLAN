//
//  BSSID.swift
//  WLAN
//
//  Created by Alsey Coleman Miller on 7/4/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

#if os(Linux)
import Glibc
#elseif canImport(Darwin)
import Darwin
#endif

import Foundation

/// WLAN BSSID.
///
/// Represents a unique 48-bit identifier that follows MAC address conventions.
///
/// - Note: The value is always stored in host byte order.
public struct BSSID: ByteValue {
    
    // MARK: - ByteValueType
    
    /// Raw BSSID 6 byte (48 bit) value.
    public typealias ByteValue = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
    
    public static var bitWidth: Int { return 48 }
    
    // MARK: - Properties
    
    public var bytes: ByteValue
    
    // MARK: - Initialization
    
    public init(bytes: ByteValue = (0, 0, 0, 0, 0, 0)) {
        self.bytes = bytes
    }
}

public extension BSSID {
    
    /// The minimum representable value in this type.
    static var min: BSSID { return BSSID(bytes: (.min, .min, .min, .min, .min, .min)) }
    
    /// The maximum representable value in this type.
    static var max: BSSID { return BSSID(bytes: (.max, .max, .max, .max, .max, .max)) }
    
    static var zero: BSSID { return .min }
}

// MARK: - Data

public extension BSSID {
    
    static var length: Int { return 6 }
    
    init?(data: Data) {
        
        guard data.count == BSSID.length
            else { return nil }
        
        self.bytes = (data[0], data[1], data[2], data[3], data[4], data[5])
    }
    
    var data: Data {
        
        return Data([bytes.0, bytes.1, bytes.2, bytes.3, bytes.4, bytes.5])
    }
}

// MARK: - Byte Swap

extension BSSID: ByteSwap {
    
    /// A representation of this BSSID with the byte order swapped.
    public var byteSwapped: BSSID {
        
        return BSSID(bytes: (bytes.5, bytes.4, bytes.3, bytes.2, bytes.1, bytes.0))
    }
}

// MARK: - RawRepresentable

extension BSSID: RawRepresentable {
    
    /// Converts a 48 bit ethernet number to its string representation.
    public init?(rawValue: String) {
        
        // verify string
        guard rawValue.utf8.count == 17
            else { return nil }
        
        var bytes: ByteValue = (0, 0, 0, 0, 0, 0)
        
        let components = rawValue.components(separatedBy: ":")
        
        guard components.count == 6
            else { return nil }
        
        for (index, string) in components.enumerated() {
            
            guard let byte = UInt8(string, radix: 16)
                else { return nil }
            
            withUnsafeMutablePointer(to: &bytes) {
                $0.withMemoryRebound(to: UInt8.self, capacity: 6) {
                    $0.advanced(by: index).pointee = byte
                }
            }
        }
        
        self.init(bigEndian: BSSID(bytes: bytes))
    }
    
    public var rawValue: String {
        
        let bytes = self.bigEndian.bytes
        
        return String(format: "%02X:%02X:%02X:%02X:%02X:%02X", bytes.0, bytes.1, bytes.2, bytes.3, bytes.4, bytes.5)
    }
}

// MARK: - Equatable

extension BSSID: Equatable {
    
    public static func == (lhs: BSSID, rhs: BSSID) -> Bool {
        
        return lhs.bytes.0 == rhs.bytes.0
            && lhs.bytes.1 == rhs.bytes.1
            && lhs.bytes.2 == rhs.bytes.2
            && lhs.bytes.3 == rhs.bytes.3
            && lhs.bytes.4 == rhs.bytes.4
            && lhs.bytes.5 == rhs.bytes.5
    }
}

// MARK: - Hashable

extension BSSID: Hashable {
    
    public var hashValue: Int {
        
        let int64Bytes = (bytes.0, bytes.1, bytes.2, bytes.3, bytes.4, bytes.5, UInt8(0), UInt8(0)) // 2 bytes for padding
        
        let int64Value = unsafeBitCast(int64Bytes, to: Int64.self)
        
        return int64Value.hashValue
    }
}

// MARK: - CustomStringConvertible

extension BSSID: CustomStringConvertible {
    
    public var description: String { return rawValue }
}
