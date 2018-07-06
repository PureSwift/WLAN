//
//  BitMaskOption.swift
//  WLAN
//
//  Created by Alsey Coleman Miller on 7/6/18.
//
//

// MARK: - BitMaskOption

#if swift(>=4.0)
    
    /// Enum that represents a bit mask flag / option.
    ///
    /// Basically `Swift.OptionSet` for enums.
    public protocol BitMaskOption: RawRepresentable, Hashable where RawValue: FixedWidthInteger {
    
    }
    
#elseif swift(>=3.2)
    
    /// Enum that represents a bit mask flag / option.
    ///
    /// Basically `Swift.OptionSet` for enums.
    public protocol BitMaskOption: RawRepresentable, Hashable where RawValue: Integer {
        
    }
    
#elseif swift(>=3.0.2)
    
    /// Enum that represents a bit mask flag / option.
    ///
    /// Basically `Swift.OptionSet` for enums.
    public protocol BitMaskOption: RawRepresentable, Hashable {
        
        associatedtype RawValue: Integer
    }
    
#endif

#if swift(>=4.0)
    
    public extension Sequence where Element: BitMaskOption {
    
        /// Convert Swift enums for bit mask options into their raw values OR'd.
        var rawValue: Element.RawValue {
    
            @inline(__always)
            get { return reduce(0, { $0 | $1.rawValue }) }
        }
    }
    
#elseif swift(>=3.0.2)
    
    public extension Sequence where Iterator.Element: BitMaskOption {
        
        /// Convert Swift enums for bit mask options into their raw values OR'd.
        var rawValue: Iterator.Element.RawValue {
            
            @inline(__always)
            get { return reduce(0, { $0 | $1.rawValue }) }
        }
    }
    
#endif

public extension BitMaskOption {
    
    /// Whether the enum case is present in the raw value.
    @inline(__always)
    func isContained(in rawValue: RawValue) -> Bool {
        
        return (self.rawValue & rawValue) != 0
    }
}

// MARK: - BitMaskOptionSet

/// Integer-backed array type for `BitMaskOption`.
///
/// The elements are packed in the integer with bitwise math and stored on the stack.
public struct BitMaskOptionSet <Element: BitMaskOption>: RawRepresentable {
    
    public typealias RawValue = Element.RawValue
    
    public fileprivate(set) var rawValue: RawValue
    
    @inline(__always)
    public init(rawValue: RawValue) {
        
        self.rawValue = rawValue
    }
    
    @inline(__always)
    public init() {
        
        self.rawValue = 0
    }
    
    @inline(__always)
    public mutating func insert(_ element: Element) {
        
        rawValue = rawValue | element.rawValue
    }
    
    @discardableResult
    public mutating func remove(_ element: Element) -> Bool {
        
        guard contains(element) else { return false }
        
        rawValue = rawValue & ~element.rawValue
        
        return true
    }
    
    @inline(__always)
    public mutating func removeAll() {
    
        self.rawValue = 0
    }
    
    @inline(__always)
    public func contains(_ element: Element) -> Bool {
        
        return element.isContained(in: rawValue)
    }
    
    public func contains <S: Sequence> (_ other: S) -> Bool where S.Iterator.Element == Element {
        
        for element in other {
            
            guard element.isContained(in: rawValue)
                else { return false }
        }
        
        return true
    }
    
    public var isEmpty: Bool {
        
        return rawValue == 0
    }
}

// MARK: - Sequence Conversion

public extension BitMaskOptionSet {
    
    public init<S: Sequence>(_ sequence: S) where S.Iterator.Element == Element {
        
        self.rawValue = sequence.rawValue
    }
}

// MARK: - Equatable

extension BitMaskOptionSet: Equatable {
    
    @inline(__always)
    public static func == (lhs: BitMaskOptionSet, rhs: BitMaskOptionSet) -> Bool {
        
        return lhs.rawValue == rhs.rawValue
    }
}

// MARK: - CustomStringConvertible

extension BitMaskOptionSet: CustomStringConvertible {
    
    public var description: String {
        
        get { return rawValue.description }
    }
}

// MARK: - Hashable

extension BitMaskOptionSet: Hashable {
    
    public var hashValue: Int {
        
        return rawValue.hashValue
    }
}

// MARK: - ExpressibleByArrayLiteral

extension BitMaskOptionSet: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: Element...) {
        
        self.init(elements)
    }
}

// MARK: - ExpressibleByIntegerLiteral

// Swift 3 works better than Swift 4 compiler

#if swift(>=3.2)

extension BitMaskOptionSet: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt64) {
        
        self.init(rawValue: numericCast(value))
    }
}

#elseif swift(>=3.0)

extension BitMaskOptionSet: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: RawValue) {
        
        self.init(rawValue: value)
    }
}

#endif
