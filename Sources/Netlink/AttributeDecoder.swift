//
//  AttributeDecoder.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/28/18.
//

import Foundation

#if swift(>=3.2)
internal typealias DecoderProtocol = Swift.Decoder
#elseif swift(>=3.0)
import Codable
internal typealias DecoderProtocol = Decoder
#endif

/// Netlink Attribute Decoder
public struct NetlinkAttributeDecoder {
    
    public typealias Log = (String) -> ()
    
    // MARK: - Properties
    
    /// Any contextual information set by the user for encoding.
    public var userInfo = [CodingUserInfoKey : Any]()
    
    /// Logger handler
    public var log: Log?
    
    // MARK: - Initialization
    
    public init() { }
    
    // MARK: - Methods
    
    public func decode <T: Decodable> (_ type: T.Type, from data: Data) throws -> T {
        
        let attributes = try decode(data)
        
        let decoder = Decoder(referencing: .attributes(attributes),
                              userInfo: userInfo,
                              log: log)
        
        // decode from container
        return try T.init(from: decoder)
    }
    
    public func decode <T: Decodable, Message: NetlinkMessageProtocol> (_ type: T.Type, from message: Message) throws -> T {
        
        return try decode(type, from: message.payload)
    }
    
    public func decode <T: NetlinkMessageProtocol> (_ message: T) throws -> [NetlinkAttribute] {
        
        return try decode(message.payload)
    }
    
    public func decode(_ data: Data) throws -> [NetlinkAttribute] {
        
        return try NetlinkAttributeDecoder.decode(data, codingPath: [])
    }
    
    internal static func decode(_ data: Data, codingPath: [CodingKey]) throws -> [NetlinkAttribute] {
        
        var attributes = [NetlinkAttribute]()
        
        var index = 0
        while index < data.count {
            
            let length = Int(UInt16(bytes: (data[index], data[index + 1])))
            
            guard length > 0  else {
                
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Could not decode attribute at index \(index)"))
            }
            
            let actualLength = length.extendTo4Bytes
            
            let attributeData = Data(data[index ..< index + actualLength])
            
            guard let attribute = NetlinkAttribute(data: attributeData) else {
                
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Could not decode attribute at index \(index)"))
            }
            
            attributes.append(attribute)
            
            index += actualLength
        }
        
        return attributes
    }
}

internal extension NetlinkAttributeDecoder {
    
    final class Decoder: DecoderProtocol {
        
        /// The path of coding keys taken to get to this point in decoding.
        fileprivate(set) var codingPath: [CodingKey]
        
        /// Any contextual information set by the user for decoding.
        let userInfo: [CodingUserInfoKey : Any]
        
        fileprivate var stack: Stack
        
        /// Logger
        let log: Log?
        
        // MARK: - Initialization
        
        fileprivate init(referencing container: Stack.Container,
                         at codingPath: [CodingKey] = [],
                         userInfo: [CodingUserInfoKey : Any],
                         log: Log?) {
            
            self.stack = Stack(container)
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.log = log
        }
        
        // MARK: - Methods
        
        func container <Key: CodingKey> (keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
            
            log?("Requested container keyed by \(type) for path \"\(codingPathString)\"")
            
            let container = self.stack.top
            
            switch container {
                
            case let .attributes(attributes):
                
                let keyedContainer = AttributesKeyedDecodingContainer<Key>(referencing: self, wrapping: attributes)
                
                return KeyedDecodingContainer(keyedContainer)
                
            case let .attribute(attribute):
                
                let attributes = try decode(attribute.payload, codingPath: codingPath)
                
                let keyedContainer = AttributesKeyedDecodingContainer<Key>(referencing: self, wrapping: attributes)
                
                return KeyedDecodingContainer(keyedContainer)
            }
        }
        
        func unkeyedContainer() throws -> UnkeyedDecodingContainer {
            
            log?("Requested unkeyed container for path \"\(codingPathString)\"")
            
            let container = self.stack.top
            
            switch container {
                
            case let .attributes(attributes):
                
                return AttributesUnkeyedDecodingContainer(referencing: self, wrapping: attributes)
                
            case let .attribute(attribute):
                
                // forceably cast to array
                guard let attributes = try? decode(attribute.payload, codingPath: codingPath) else {
                    
                    throw DecodingError.typeMismatch(UnkeyedDecodingContainer.self, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot get unkeyed decoding container, invalid top container \(container)."))
                }
                
                // replace stack
                self.stack.pop()
                self.stack.push(.attributes(attributes))
                
                return AttributesUnkeyedDecodingContainer(referencing: self, wrapping: attributes)
            }
        }
        
        func singleValueContainer() throws -> SingleValueDecodingContainer {
            
            log?("Requested single value container for path \"\(codingPathString)\"")
            
            let container = self.stack.top
            
            guard case let .attribute(attribute) = container else {
                
                throw DecodingError.typeMismatch(SingleValueDecodingContainer.self, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot get single value decoding container, invalid top container \(container)."))
            }
            
            return AttributeSingleValueDecodingContainer(referencing: self, wrapping: attribute)
        }
    }
}


// MARK: - Unboxing Values

fileprivate extension NetlinkAttributeDecoder.Decoder {
    
    /// KVC path string for current coding path.
    var codingPathString: String {
        
        return codingPath.reduce("", { $0 + "\($0.isEmpty ? "" : ".")" + $1.stringValue })
    }
    
    func unbox <T: NetlinkAttributeDecodable> (_ attributeData: Data, as type: T.Type) throws -> T {
        
        guard let value = T.init(attributeData: attributeData) else {
            
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Could not parse \(type) from \(attributeData)"))
        }
        
        return value
    }
    
    /// Attempt to decode native value to expected type.
    func unboxDecodable <T: Decodable> (_ attribute: NetlinkAttribute, as type: T.Type) throws -> T {
        
        // override for native types
        if type == Data.self {
            
            return attribute.payload as! T
            
        } else {
            
            // push container to stack and decode using Decodable implementation
            stack.push(.attribute(attribute))
            let decoded = try T(from: self)
            stack.pop()
            
            return decoded
        }
    }
}

// MARK: - Stack

fileprivate extension NetlinkAttributeDecoder {
    
    fileprivate struct Stack {
        
        private(set) var containers = [Container]()
        
        fileprivate init(_ container: Container) {
            
            self.containers = [container]
        }
        
        var top: Container {
            
            guard let container = containers.last
                else { fatalError("Empty container stack.") }
            
            return container
        }
        
        mutating func push(_ container: Container) {
            
            containers.append(container)
        }
        
        @discardableResult
        mutating func pop() -> Container {
            
            guard let container = containers.popLast()
                else { fatalError("Empty container stack.") }
            
            return container
        }
    }
}

fileprivate extension NetlinkAttributeDecoder.Stack {
    
    enum Container {
        
        case attributes([NetlinkAttribute])
        case attribute(NetlinkAttribute)
    }
}


// MARK: - KeyedDecodingContainer

internal extension NetlinkAttributeDecoder {
    
    struct AttributesKeyedDecodingContainer <K : CodingKey >: KeyedDecodingContainerProtocol {
        
        typealias Key = K
        
        // MARK: Properties
        
        /// A reference to the encoder we're reading from.
        private let decoder: NetlinkAttributeDecoder.Decoder
        
        /// A reference to the container we're reading from.
        private let container: [NetlinkAttribute]
        
        /// The path of coding keys taken to get to this point in decoding.
        public let codingPath: [CodingKey]
        
        /// All the keys the Decoder has for this container.
        public let allKeys: [Key]
        
        // MARK: Initialization
        
        /// Initializes `self` by referencing the given decoder and container.
        fileprivate init(referencing decoder: NetlinkAttributeDecoder.Decoder, wrapping container: [NetlinkAttribute]) {
            
            self.decoder = decoder
            self.container = container
            self.codingPath = decoder.codingPath
            self.allKeys = container.flatMap { Key(intValue: Int($0.type.rawValue)) }
        }
        
        // MARK: KeyedDecodingContainerProtocol
        
        func contains(_ key: Key) -> Bool {
            
            // log
            self.decoder.log?("Check whether key \"\(key.stringValue)\" exists")
            
            // check schema / model contains property
            guard allKeys.contains(where: { $0.stringValue == key.stringValue })
                else { return false }
            
            // return whether value exists for key
            return container.contains { $0.type == NetlinkAttributeType(codingKey: key) }
        }
        
        func decodeNil(forKey key: Key) throws -> Bool {
            
            // set coding key context
            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }
            
            return try self.value(for: key) == nil
        }
        
        func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
            
            return try _decode(type, forKey: key)
        }
        
        func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
            
            let value = try _decode(Int32.self, forKey: key)
            
            return Int(value)
        }
        
        func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
            
            return try _decode(type, forKey: key)
        }
        
        func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
            
            return try _decode(type, forKey: key)
        }
        
        func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
            
            return try _decode(type, forKey: key)
        }
        
        func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
            
            return try _decode(type, forKey: key)
        }
        
        func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
            
            let value = try _decode(UInt32.self, forKey: key)
            
            return UInt(value)
        }
        
        func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
            
            return try _decode(type, forKey: key)
        }
        
        func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
            
            return try _decode(type, forKey: key)
        }
        
        func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
            
            return try _decode(type, forKey: key)
        }
        
        func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
            
            return try _decode(type, forKey: key)
        }
        
        func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
            
            //return try _decode(type, forKey: key)
            fatalError()
        }
        
        func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
            
            //return try _decode(type, forKey: key)
            fatalError()
        }
        
        func decode(_ type: String.Type, forKey key: Key) throws -> String {
            
            return try _decode(type, forKey: key)
        }
        
        func decode <T: Decodable> (_ type: T.Type, forKey key: Key) throws -> T {
            
            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }
            
            guard let attribute = try self.value(for: key) else {
                
                throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
            }
            
            let value = try self.decoder.unboxDecodable(attribute, as: type)
            
            return value
        }
        
        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            
            fatalError()
        }
        
        func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            
            fatalError()
        }
        
        func superDecoder() throws -> DecoderProtocol {
            
            fatalError()
        }
        
        func superDecoder(forKey key: Key) throws -> DecoderProtocol {
            
            fatalError()
        }
        
        // MARK: Private Methods
        
        /// Decode native value type from attribute data.
        private func _decode <T: NetlinkAttributeDecodable> (_ type: T.Type, forKey key: Key) throws -> T {
            
            self.decoder.codingPath.append(key)
            defer { self.decoder.codingPath.removeLast() }
            
            guard let attribute = try self.value(for: key) else {
                
                throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
            }
            
            let attributeData = attribute.payload
            
            let value = try decoder.unbox(attributeData, as: type)
            
            return value
        }
        
        /// Access actual value
        private func value(for key: Key) throws -> NetlinkAttribute? {
            
            // log
            decoder.log?("Will read value for key \(key.stringValue) at path \"\(decoder.codingPathString)\"")
            
            // get value
            return container.first { $0.type == NetlinkAttributeType(codingKey: key) }
        }
    }
}

// MARK: - SingleValueDecodingContainer

fileprivate extension NetlinkAttributeDecoder {
    
    fileprivate struct AttributeSingleValueDecodingContainer: SingleValueDecodingContainer {
        
        // MARK: Properties
        
        /// A reference to the decoder we're reading from.
        private let decoder: Decoder
        
        /// A reference to the container we're reading from.
        private let container: NetlinkAttribute
        
        /// The path of coding keys taken to get to this point in decoding.
        public let codingPath: [CodingKey]
        
        var attributeData: Data {
            return container.payload
        }
        
        // MARK: Initialization
        
        /// Initializes `self` by referencing the given decoder and container.
        fileprivate init(referencing decoder: Decoder, wrapping container: NetlinkAttribute) {
            
            self.decoder = decoder
            self.container = container
            self.codingPath = decoder.codingPath
        }
        
        // MARK: SingleValueDecodingContainer
        
        func decodeNil() -> Bool {
            
            return attributeData.isEmpty
        }
        
        func decode(_ type: Bool.Type) throws -> Bool {
            
            return try self.decoder.unbox(attributeData, as: type)
        }
        
        func decode(_ type: Int.Type) throws -> Int {
            
            let value = try self.decoder.unbox(attributeData, as: Int32.self)
            
            return Int(value)
        }
        
        func decode(_ type: Int8.Type) throws -> Int8 {
            
            return try self.decoder.unbox(attributeData, as: type)
        }
        
        func decode(_ type: Int16.Type) throws -> Int16 {
            
            return try self.decoder.unbox(attributeData, as: type)
        }
        
        func decode(_ type: Int32.Type) throws -> Int32 {
            
            return try self.decoder.unbox(attributeData, as: type)
        }
        
        func decode(_ type: Int64.Type) throws -> Int64 {
            
            return try self.decoder.unbox(attributeData, as: type)
        }
        
        func decode(_ type: UInt.Type) throws -> UInt {
            
            let value = try self.decoder.unbox(attributeData, as: UInt32.self)
            
            return UInt(value)
        }
        
        func decode(_ type: UInt8.Type) throws -> UInt8 {
            
            return try self.decoder.unbox(attributeData, as: type)
        }
        
        func decode(_ type: UInt16.Type) throws -> UInt16 {
            
            return try self.decoder.unbox(attributeData, as: type)
        }
        
        func decode(_ type: UInt32.Type) throws -> UInt32 {
            
            return try self.decoder.unbox(attributeData, as: type)
        }
        
        func decode(_ type: UInt64.Type) throws -> UInt64 {
            
            return try self.decoder.unbox(attributeData, as: type)
        }
        
        func decode(_ type: Float.Type) throws -> Float {
            
            fatalError()
        }
        
        func decode(_ type: Double.Type) throws -> Double {
            
            fatalError()
        }
        
        func decode(_ type: String.Type) throws -> String {
            
            return try self.decoder.unbox(attributeData, as: type)
        }
        
        func decode <T : Decodable> (_ type: T.Type) throws -> T {
            
            return try self.decoder.unboxDecodable(container, as: type)
        }
    }
}


// MARK: UnkeyedDecodingContainer

fileprivate extension NetlinkAttributeDecoder {
    
    fileprivate struct AttributesUnkeyedDecodingContainer: UnkeyedDecodingContainer {
        
        // MARK: Properties
        
        /// A reference to the encoder we're reading from.
        fileprivate let decoder: Decoder
        
        /// A reference to the container we're reading from.
        fileprivate let container: [NetlinkAttribute]
        
        /// The path of coding keys taken to get to this point in decoding.
        public let codingPath: [CodingKey]
        
        public private(set) var currentIndex: Int = 0
        
        // MARK: Initialization
        
        /// Initializes `self` by referencing the given decoder and container.
        fileprivate init(referencing decoder: Decoder, wrapping container: [NetlinkAttribute]) {
            
            self.decoder = decoder
            self.container = container
            self.codingPath = decoder.codingPath
        }
        
        // MARK: UnkeyedDecodingContainer
        
        public var count: Int? {
            return _count
        }
        
        public var _count: Int {
            return container.count
        }
        
        public var isAtEnd: Bool {
            return currentIndex >= _count
        }
        
        mutating func decodeNil() throws -> Bool {
            
            try assertNotEnd()
            
            // never optional, decode
            return false
        }
        
        mutating func decode(_ type: Bool.Type) throws -> Bool { fatalError("stub") }
        mutating func decode(_ type: Int.Type) throws -> Int { fatalError("stub") }
        mutating func decode(_ type: Int8.Type) throws -> Int8 { fatalError("stub") }
        mutating func decode(_ type: Int16.Type) throws -> Int16 { fatalError("stub") }
        mutating func decode(_ type: Int32.Type) throws -> Int32 { fatalError("stub") }
        mutating func decode(_ type: Int64.Type) throws -> Int64 { fatalError("stub") }
        mutating func decode(_ type: UInt.Type) throws -> UInt { fatalError("stub") }
        mutating func decode(_ type: UInt8.Type) throws -> UInt8 { fatalError("stub") }
        mutating func decode(_ type: UInt16.Type) throws -> UInt16 { fatalError("stub") }
        mutating func decode(_ type: UInt32.Type) throws -> UInt32 { fatalError("stub") }
        mutating func decode(_ type: UInt64.Type) throws -> UInt64 { fatalError("stub") }
        mutating func decode(_ type: Float.Type) throws -> Float { fatalError("stub") }
        mutating func decode(_ type: Double.Type) throws -> Double { fatalError("stub") }
        mutating func decode(_ type: String.Type) throws -> String { fatalError("stub") }
        
        mutating func decode <T : Decodable> (_ type: T.Type) throws -> T {
            
            try assertNotEnd()
            
            self.decoder.codingPath.append(Index(intValue: self.currentIndex))
            defer { self.decoder.codingPath.removeLast() }
            
            let attribute = self.container[self.currentIndex]
            
            let decoded = try self.decoder.unboxDecodable(attribute, as: type)
            
            self.currentIndex += 1
            
            return decoded
        }
        
        mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode \(type)"))
        }
        
        mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
            
            throw DecodingError.typeMismatch([Any].self, DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode unkeyed container."))
        }
        
        mutating func superDecoder() throws -> DecoderProtocol {
            
            // set coding key context
            self.decoder.codingPath.append(Index(intValue: currentIndex))
            defer { self.decoder.codingPath.removeLast() }
            
            // log
            self.decoder.log?("Requested super decoder for path \"\(self.decoder.codingPathString)\"")
            
            // check for end of array
            try assertNotEnd()
            
            // get attribute
            let attribute = container[currentIndex]
            
            // increment counter
            self.currentIndex += 1
            
            // create new decoder
            let decoder = Decoder(referencing: .attribute(attribute),
                                  at: self.decoder.codingPath,
                                  userInfo: self.decoder.userInfo,
                                  log: self.decoder.log)
            
            return decoder
        }
        
        // MARK: Private Methods
        
        @inline(__always)
        private func assertNotEnd() throws {
            
            guard isAtEnd == false else {
                
                throw DecodingError.valueNotFound(Any?.self, DecodingError.Context(codingPath: self.decoder.codingPath + [Index(intValue: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
            }
        }
    }
}

fileprivate extension NetlinkAttributeDecoder.AttributesUnkeyedDecodingContainer {
    
    struct Index: CodingKey {
        
        public let index: Int
        
        public init(intValue: Int) {
            
            self.index = intValue
        }
        
        init?(stringValue: String) {
            
            return nil
        }
        
        public var intValue: Int? {
            return index
        }
        
        public var stringValue: String {
            return "\(index)"
        }
    }
}

// MARK: - Decodable Types

/// Decoding from raw NetLink Attribute data.
public protocol NetlinkAttributeDecodable {
    
    /// Decodes from a single attribute.
    init?(attributeData: Data)
}

extension String: NetlinkAttributeDecodable {
    
    public init?(attributeData data: Data) {
        
        self = data.withUnsafeBytes { (cString: UnsafePointer<UInt8>) in
            String(cString: cString)
        }
    }
}

extension Bool: NetlinkAttributeDecodable {
    
    public init?(attributeData data: Data) {
        
        guard data.count == MemoryLayout<UInt8>.size
            else { return nil }
        
        self = data[0] != 0
    }
}

extension UInt8: NetlinkAttributeDecodable {
    
    public init?(attributeData data: Data) {
        
        guard data.count == MemoryLayout<UInt8>.size
            else { return nil }
        
        self = data[0]
    }
}

extension UInt16: NetlinkAttributeDecodable {
    
    public init?(attributeData data: Data) {
        
        guard data.count == MemoryLayout<UInt16>.size
            else { return nil }
        
        self.init(bytes: (data[0], data[1]))
    }
}

extension UInt32: NetlinkAttributeDecodable {
    
    public init?(attributeData data: Data) {
        
        guard data.count == MemoryLayout<UInt32>.size
            else { return nil }
        
        self.init(bytes: (data[0], data[1], data[2], data[3]))
    }
}

extension UInt64: NetlinkAttributeDecodable {
    
    public init?(attributeData data: Data) {
        
        guard data.count == MemoryLayout<UInt64>.size
            else { return nil }
        
        self.init(bytes: (data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7]))
    }
}

extension Int8: NetlinkAttributeDecodable {
    
    public init?(attributeData data: Data) {
        
        guard data.count == MemoryLayout<Int8>.size
            else { return nil }
        
        self = Int8(bitPattern: data[0])
    }
}

extension Int16: NetlinkAttributeDecodable {
    
    public init?(attributeData data: Data) {
        
        guard data.count == MemoryLayout<Int16>.size
            else { return nil }
        
        self.init(bytes: (data[0], data[1]))
    }
}

extension Int32: NetlinkAttributeDecodable {
    
    public init?(attributeData data: Data) {
        
        guard data.count == MemoryLayout<Int32>.size
            else { return nil }
        
        self.init(bytes: (data[0], data[1], data[2], data[3]))
    }
}

extension Int64: NetlinkAttributeDecodable {
    
    public init?(attributeData data: Data) {
        
        guard data.count == MemoryLayout<Int32>.size
            else { return nil }
        
        self.init(bytes: (data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7]))
    }
}
