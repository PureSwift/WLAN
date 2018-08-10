//
//  AttributeEncoder.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/28/18.
//

import Foundation

#if swift(>=3.2)
    internal typealias EncoderProtocol = Swift.Encoder
    public typealias CodableEncodingError = Swift.EncodingError
#elseif swift(>=3.0)
    import Codable
    internal typealias EncoderProtocol = Encoder
    public typealias CodableEncodingError = EncodingError
#endif

/// Netlink Attribute Encoder
public struct NetlinkAttributeEncoder {
    
    public typealias Log = (String) -> ()
    
    // MARK: - Properties
    
    /// Any contextual information set by the user for encoding.
    public var userInfo = [CodingUserInfoKey : Any]()
    
    /// Logger handler
    public var log: Log?
    
    // MARK: - Initialization
    
    public init() { }
    
    // MARK: - Methods
    
    public func encode <T: Encodable> (_ value: T) throws -> Data {
        
        let encoder = Encoder(userInfo: userInfo, log: log)
        
        try value.encode(to: encoder)
        
        assert(encoder.stack.containers.count == 1)
        
        guard case let .attributes(attributesContainer) = encoder.stack.root else {
            
            throw CodableEncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "Top-level \(T.self) is not encoded as attributes."))
        }
        
        return attributesContainer.data
    }
    
    public func encode(_ attributes: [NetlinkAttribute]) -> Data {
        
        return attributes.reduce(Data(), { $0.0 + $0.1.paddedData })
    }
}

public extension NetlinkAttributeEncoder {
    
    public enum EncodingError: Error {
        
        #if swift(>=3.2)
        public typealias Context = Swift.EncodingError.Context
        #elseif swift(>=3.0)
        public typealias Context = CodableEncodingError.Context
        #endif
        
        /// Invalid coding key provided.
        case invalidKey(CodingKey, Context)
    }
}

// MARK: - Encoder

internal extension NetlinkAttributeEncoder {
    
    final class Encoder: EncoderProtocol {
        
        // MARK: - Properties
        
        /// The path of coding keys taken to get to this point in encoding.
        fileprivate(set) var codingPath: [CodingKey]
        
        /// Any contextual information set by the user for encoding.
        let userInfo: [CodingUserInfoKey : Any]
        
        /// Logger
        let log: Log?
        
        fileprivate var stack: Stack
        
        // MARK: - Initialization
        
        init(codingPath: [CodingKey] = [],
             userInfo: [CodingUserInfoKey : Any],
             log: Log?) {
            
            self.stack = Stack()
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.log = log
        }
        
        // MARK: - Encoder
        
        func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
            
            log?("Requested container keyed by \(type) for path \"\(codingPathString)\"")
            
            let stackContainer = AttributesContainer()
            self.stack.push(.attributes(stackContainer))
            
            let keyedContainer = KeyedContainer<Key>(referencing: self, wrapping: stackContainer)
            
            return KeyedEncodingContainer(keyedContainer)
        }
        
        func unkeyedContainer() -> UnkeyedEncodingContainer {
            
            log?("Requested unkeyed container for path \"\(codingPathString)\"")
            
            let stackContainer = AttributesContainer()
            self.stack.push(.attributes(stackContainer))
            
            return AttributesUnkeyedEncodingContainer(referencing: self, wrapping: stackContainer)
        }
        
        func singleValueContainer() -> SingleValueEncodingContainer {
            
            log?("Requested single value container for path \"\(codingPathString)\"")
            
            let stackContainer = AttributeContainer()
            self.stack.push(.attribute(stackContainer))
            
            return AttributeSingleValueEncodingContainer(referencing: self, wrapping: stackContainer)
        }
    }
}

internal extension NetlinkAttributeEncoder.Encoder {
    
    /// KVC path string for current coding path.
    var codingPathString: String {
        
        return codingPath.reduce("", { $0 + "\($0.isEmpty ? "" : ".")" + $1.stringValue })
    }
    
    func attributeType <Key: CodingKey> (for key: Key) throws -> NetlinkAttributeType {
        
        if let attributeKey = key as? NetlinkAttributeCodingKey {
            
            // no need to reinvent the wheel
            return attributeKey.attribute
            
        } else {
            
            // reinvent the wheel
            guard let intValue = key.intValue else {
                
                throw NetlinkAttributeEncoder.EncodingError.invalidKey(key, EncodingError.Context(codingPath: codingPath, debugDescription: "\(key) has no integer value"))
            }
            
            // validate `UInt16` value
            guard intValue <= Int(UInt16.max),
                intValue >= Int(UInt16.min) else {
                    
                    throw NetlinkAttributeEncoder.EncodingError.invalidKey(key, EncodingError.Context(codingPath: codingPath, debugDescription: "\(key) has an invalid integer value \(intValue)"))
            }
            
            return NetlinkAttributeType(rawValue: UInt16(intValue))
        }
    }
}

internal extension NetlinkAttributeEncoder.Encoder {
    
    @inline(__always)
    func box <T: NetlinkAttributeEncodable> (_ value: T) -> Data {
        
        return value.attributeData
    }
    
    func boxEncodable <T: Encodable> (_ value: T) throws -> Data {
        
        if let attributeValue = value as? NetlinkAttributeEncodable {
            
            return attributeValue.attributeData
            
        } else if let dataValue = value as? Data {
            
            return dataValue
            
        } else {
            
            // encode using Encodable, should push new container.
            try value.encode(to: self)
            let nestedContainer = stack.pop()
            
            return nestedContainer.data
        }
    }
}

// MARK: - Stack

internal extension NetlinkAttributeEncoder.Encoder {
    
    internal struct Stack {
        
        private(set) var containers = [Container]()
        
        fileprivate init() { }
        
        var top: Container {
            
            guard let container = containers.last
                else { fatalError("Empty container stack.") }
            
            return container
        }
        
        var root: Container {
            
            guard let container = containers.first
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

internal extension NetlinkAttributeEncoder.Encoder {
    
    final class AttributesContainer {
        
        var attributes = [NetlinkAttribute]()
        
        fileprivate init() { }
        
        var data: Data {
            
            let size = attributes.reduce(0, { $0.0 + $0.1.paddedLength })
            
            return attributes.reduce(Data(capacity: size), { $0.0 + $0.1.paddedData })
        }
    }
    
    final class AttributeContainer {
        
        var data: Data
        
        fileprivate init(_ data: Data = Data()) {
            
            self.data = data
        }
    }
    
    enum Container {
        
        case attributes(AttributesContainer)
        case attribute(AttributeContainer)
        
        var data: Data {
            
            switch self {
            case let .attributes(container):
                return container.data
            case let .attribute(container):
                return container.data
            }
        }
    }
}

// MARK: - KeyedEncodingContainerProtocol

internal extension NetlinkAttributeEncoder.Encoder {
    
    final class KeyedContainer <K : CodingKey> : KeyedEncodingContainerProtocol {
        
        typealias Key = K
        
        // MARK: - Properties
        
        /// A reference to the encoder we're writing to.
        let encoder: NetlinkAttributeEncoder.Encoder
        
        /// The path of coding keys taken to get to this point in encoding.
        let codingPath: [CodingKey]
        
        /// A reference to the container we're writing to.
        let container: AttributesContainer
        
        // MARK: - Initialization
        
        init(referencing encoder: NetlinkAttributeEncoder.Encoder,
             wrapping container: AttributesContainer) {
            
            self.encoder = encoder
            self.codingPath = encoder.codingPath
            self.container = container
        }
        
        // MARK: - Methods
        
        func encodeNil(forKey key: K) throws { try _encode(NetlinkAttributeEncoder.Encoder.Null(), forKey: key) }
        
        func encode(_ value: Bool, forKey key: K) throws { try _encode(value, forKey: key) }
        
        func encode(_ value: Int, forKey key: K) throws { try _encode(Int32(value), forKey: key) }
        
        func encode(_ value: Int8, forKey key: K) throws { try _encode(value, forKey: key) }
        
        func encode(_ value: Int16, forKey key: K) throws { try _encode(value, forKey: key) }
        
        func encode(_ value: Int32, forKey key: K) throws { try _encode(value, forKey: key) }
        
        func encode(_ value: Int64, forKey key: K) throws { try _encode(value, forKey: key) }
        
        func encode(_ value: UInt, forKey key: K) throws { try _encode(UInt32(value), forKey: key) }
        
        func encode(_ value: UInt8, forKey key: K) throws { try _encode(value, forKey: key) }
        
        func encode(_ value: UInt16, forKey key: K) throws { try _encode(value, forKey: key) }
        
        func encode(_ value: UInt32, forKey key: K) throws { try _encode(value, forKey: key) }
        
        func encode(_ value: UInt64, forKey key: K) throws { try _encode(value, forKey: key) }
        
        func encode(_ value: Float, forKey key: K) throws { try _encode(value, forKey: key) }
        
        func encode(_ value: Double, forKey key: K) throws { try _encode(value, forKey: key) }
        
        func encode(_ value: String, forKey key: K) throws { try _encode(value, forKey: key) }
        
        func encode <T: Encodable> (_ value: T, forKey key: K) throws {
            
            self.encoder.codingPath.append(key)
            defer { self.encoder.codingPath.removeLast() }
            
            let data = try encoder.boxEncodable(value)
            
            try setValue(data, for: key)
        }
        
        func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            
            fatalError()
        }
        
        func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
            
            fatalError()
        }
        
        func superEncoder() -> EncoderProtocol {
            
            fatalError()
        }
        
        func superEncoder(forKey key: K) -> EncoderProtocol {
            
            fatalError()
        }
        
        // MARK: - Private Methods
        
        private func _encode <T: NetlinkAttributeEncodable> (_ value: T, forKey key: K) throws {
            
            self.encoder.codingPath.append(key)
            defer { self.encoder.codingPath.removeLast() }
            
            let data = encoder.box(value)
            
            try setValue(data, for: key)
        }
        
        private func setValue(_ value: Data, for key: Key) throws {
            
            encoder.log?("Will encode value for key \(key.stringValue) at path \"\(encoder.codingPathString)\"")
            
            let type = try encoder.attributeType(for: key)
            
            self.container.attributes.append(NetlinkAttribute(type: type, payload: value))
        }
    }
}

// MARK: - SingleValueEncodingContainer

internal extension NetlinkAttributeEncoder.Encoder {
    
    final class AttributeSingleValueEncodingContainer: SingleValueEncodingContainer {
        
        // MARK: - Properties
        
        /// A reference to the encoder we're writing to.
        let encoder: NetlinkAttributeEncoder.Encoder
        
        /// The path of coding keys taken to get to this point in encoding.
        let codingPath: [CodingKey]
        
        /// A reference to the container we're writing to.
        let container: AttributeContainer
        
        /// Whether the data has been written
        private var didWrite = false
        
        // MARK: - Initialization
        
        init(referencing encoder: NetlinkAttributeEncoder.Encoder,
             wrapping container: AttributeContainer) {
            
            self.encoder = encoder
            self.codingPath = encoder.codingPath
            self.container = container
        }
        
        // MARK: - Methods
        
        func encodeNil() throws { write(encoder.box(Null())) }
        
        func encode(_ value: Bool) throws { write(encoder.box(value)) }
        
        func encode(_ value: String) throws { write(encoder.box(value)) }
        
        func encode(_ value: Double) throws { write(encoder.box(value)) }
        
        func encode(_ value: Float) throws { write(encoder.box(value)) }
        
        func encode(_ value: Int) throws { write(encoder.box(Int32(value))) }
        
        func encode(_ value: Int8) throws { write(encoder.box(value)) }
        
        func encode(_ value: Int16) throws { write(encoder.box(value)) }
        
        func encode(_ value: Int32) throws { write(encoder.box(value)) }
        
        func encode(_ value: Int64) throws { write(encoder.box(value)) }
        
        func encode(_ value: UInt) throws { write(encoder.box(UInt32(value))) }
        
        func encode(_ value: UInt8) throws { write(encoder.box(value)) }
        
        func encode(_ value: UInt16) throws { write(encoder.box(value)) }
        
        func encode(_ value: UInt32) throws { write(encoder.box(value)) }
        
        func encode(_ value: UInt64) throws { write(encoder.box(value)) }
        
        func encode <T: Encodable> (_ value: T) throws { write(try encoder.boxEncodable(value)) }
        
        // MARK: - Private Methods
        
        private func write(_ data: Data) {
            
            assert(didWrite == false, "Data already written")
            
            self.container.data = data
            
            self.didWrite = true
        }
    }
}

// MARK: - UnkeyedEncodingContainer

internal extension NetlinkAttributeEncoder.Encoder {
    
    final class AttributesUnkeyedEncodingContainer: UnkeyedEncodingContainer {
        
        // MARK: - Properties
        
        /// A reference to the encoder we're writing to.
        let encoder: NetlinkAttributeEncoder.Encoder
        
        /// The path of coding keys taken to get to this point in encoding.
        let codingPath: [CodingKey]
        
        /// A reference to the container we're writing to.
        let container: AttributesContainer
        
        // MARK: - Initialization
        
        init(referencing encoder: NetlinkAttributeEncoder.Encoder,
             wrapping container: AttributesContainer) {
            
            self.encoder = encoder
            self.codingPath = encoder.codingPath
            self.container = container
        }
        
        // MARK: - Methods
        
        /// The number of elements encoded into the container.
        var count: Int {
            
            return container.attributes.count
        }
        
        // MARK: - Methods
        
        func encodeNil() throws { append(encoder.box(Null())) }
        
        func encode(_ value: Bool) throws { append(encoder.box(value)) }
        
        func encode(_ value: String) throws { append(encoder.box(value)) }
        
        func encode(_ value: Double) throws { append(encoder.box(value)) }
        
        func encode(_ value: Float) throws { append(encoder.box(value)) }
        
        func encode(_ value: Int) throws { append(encoder.box(Int32(value))) }
        
        func encode(_ value: Int8) throws { append(encoder.box(value)) }
        
        func encode(_ value: Int16) throws { append(encoder.box(value)) }
        
        func encode(_ value: Int32) throws { append(encoder.box(value)) }
        
        func encode(_ value: Int64) throws { append(encoder.box(value)) }
        
        func encode(_ value: UInt) throws { append(encoder.box(UInt32(value))) }
        
        func encode(_ value: UInt8) throws { append(encoder.box(value)) }
        
        func encode(_ value: UInt16) throws { append(encoder.box(value)) }
        
        func encode(_ value: UInt32) throws { append(encoder.box(value)) }
        
        func encode(_ value: UInt64) throws { append(encoder.box(value)) }
        
        func encode <T: Encodable> (_ value: T) throws { append(try encoder.boxEncodable(value)) }
        
        func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            
            fatalError()
        }
        
        func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
            
            fatalError()
        }
        
        func superEncoder() -> Encoder {
            
            fatalError()
        }
        
        // MARK: - Private Methods
        
        private func append(_ data: Data) {
            
            let index = NetlinkAttributeType(rawValue: UInt16(count))
            
            self.container.attributes.append(NetlinkAttribute(type: index, payload: data))
        }
    }
}

// MARK: - Data Types

/// Encoding to raw NetLink Attribute data.
public protocol NetlinkAttributeEncodable {
    
    /// Decodes from a single attribute.
    var attributeData: Data { get }
}

// MARK: - Common Attribute Types

private extension NetlinkAttributeEncodable {
    
    var copyingBytes: Data {
        
        var copy = self
        
        return withUnsafePointer(to: &copy, { Data(bytes: $0, count: MemoryLayout<Self>.size) })
    }
}

internal extension NetlinkAttributeEncoder.Encoder {
    
    struct Null {
        
        init() { }
    }
}

extension NetlinkAttributeEncoder.Encoder.Null: NetlinkAttributeEncodable {
    
    public var attributeData: Data {
        
        return Data()
    }
}

extension UInt8: NetlinkAttributeEncodable {
    
    public var attributeData: Data {
        
        return copyingBytes
    }
}

extension UInt16: NetlinkAttributeEncodable {
    
    public var attributeData: Data {
        
        return copyingBytes
    }
}

extension UInt32: NetlinkAttributeEncodable {
    
    public var attributeData: Data {
        
        return copyingBytes
    }
}

extension UInt64: NetlinkAttributeEncodable {
    
    public var attributeData: Data {
        
        return copyingBytes
    }
}

extension Int8: NetlinkAttributeEncodable {
    
    public var attributeData: Data {
        
        return copyingBytes
    }
}

extension Int16: NetlinkAttributeEncodable {
    
    public var attributeData: Data {
        
        return copyingBytes
    }
}

extension Int32: NetlinkAttributeEncodable {
    
    public var attributeData: Data {
        
        return copyingBytes
    }
}

extension Int64: NetlinkAttributeEncodable {
    
    public var attributeData: Data {
        
        return copyingBytes
    }
}

extension Float: NetlinkAttributeEncodable {
    
    public var attributeData: Data {
        
        return copyingBytes
    }
}

extension Double: NetlinkAttributeEncodable {
    
    public var attributeData: Data {
        
        return copyingBytes
    }
}

extension Bool: NetlinkAttributeEncodable {
    
    public var attributeData: Data {
        
        return UInt8(self ? 1 : 0).copyingBytes
    }
}

extension String: NetlinkAttributeEncodable {
    
    public var attributeData: Data {
        
        return Data(unsafeBitCast(utf8CString, to: ContiguousArray<UInt8>.self))
    }
}
