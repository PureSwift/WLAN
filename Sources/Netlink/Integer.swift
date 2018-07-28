//
//  Integer.swift
//  SwiftFoundation
//
//  Created by Alsey Coleman Miller on 8/24/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

import Foundation

internal extension size_t {
    
    var extendTo4Bytes: size_t {
        
        return self + ((4 - (self & 3)) & 3);
    }
}

internal extension Int64 {
    
    func toInt() -> Int? {
        
        // Can't convert to Int if the stored value is larger than the max value of Int
        guard self <= Int64(Int.max) else { return nil }
        
        return Int(self)
    }
}

internal extension Int {
    
    func toInt64() -> Int64 {
        
        return Int64(self)
    }
}

internal extension UInt16 {
    
    /// Initializes value from two bytes.
    init(bytes: (UInt8, UInt8)) {
        
        self = unsafeBitCast(bytes, to: UInt16.self)
    }
    
    /// Converts to two bytes. 
    var bytes: (UInt8, UInt8) {
        
        return unsafeBitCast(self, to: (UInt8, UInt8).self)
    }
}

internal extension Int16 {
    
    /// Initializes value from two bytes.
    init(bytes: (UInt8, UInt8)) {
        
        self = unsafeBitCast(bytes, to: Int16.self)
    }
    
    /// Converts to two bytes.
    var bytes: (UInt8, UInt8) {
        
        return unsafeBitCast(self, to: (UInt8, UInt8).self)
    }
}

internal extension UInt32 {
    
    /// Initializes value from four bytes.
    init(bytes: (UInt8, UInt8, UInt8, UInt8)) {
        
        self = unsafeBitCast(bytes, to: UInt32.self)
    }
    
    /// Converts to four bytes.
    var bytes: (UInt8, UInt8, UInt8, UInt8) {
        
        return unsafeBitCast(self, to: (UInt8, UInt8, UInt8, UInt8).self)
    }
}

internal extension Int32 {
    
    /// Initializes value from four bytes.
    init(bytes: (UInt8, UInt8, UInt8, UInt8)) {
        
        self = unsafeBitCast(bytes, to: Int32.self)
    }
    
    /// Converts to four bytes.
    var bytes: (UInt8, UInt8, UInt8, UInt8) {
        
        return unsafeBitCast(self, to: (UInt8, UInt8, UInt8, UInt8).self)
    }
}

internal extension UInt64 {
    
    /// Initializes value from four bytes.
    init(bytes: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)) {
        
        self = unsafeBitCast(bytes, to: UInt64.self)
    }
    
    /// Converts to eight bytes.
    var bytes: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) {
        
        return unsafeBitCast(self, to: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8).self)
    }
}

internal extension Int64 {
    
    /// Initializes value from four bytes.
    init(bytes: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)) {
        
        self = unsafeBitCast(bytes, to: Int64.self)
    }
    
    /// Converts to eight bytes.
    var bytes: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) {
        
        return unsafeBitCast(self, to: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8).self)
    }
}
