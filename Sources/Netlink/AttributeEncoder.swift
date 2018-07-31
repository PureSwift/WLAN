//
//  AttributeEncoder.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/28/18.
//

import Foundation

#if swift(>=3.2)
    internal typealias EncoderProtocol = Swift.Encoder
#elseif swift(>=3.0)
    import Codable
    internal typealias EncoderProtocol = Encoder
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
        
        return encoder.stack.top.data
    }
}

public extension NetlinkAttributeEncoder {
    
    public enum EncodingError: Error {
        
        public typealias Context = Swift.EncodingError.Context
        
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
            
            fatalError()
        }
        
        func unkeyedContainer() -> UnkeyedEncodingContainer {
            
            fatalError()
        }
        
        func singleValueContainer() -> SingleValueEncodingContainer {
            
            fatalError()
        }
        
    }
}

internal extension NetlinkAttributeEncoder.Encoder {
    
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

// MARK: - Stack

internal extension NetlinkAttributeEncoder.Encoder {
    
    internal struct Stack {
        
        private(set) var containers: [Container]
        
        init() {
            
            self.containers = [Container()]
        }
        
        var top: Container {
            
            guard let container = containers.last
                else { fatalError("Empty container stack.") }
            
            return container
        }
        
        mutating func append(_ attribute: NetlinkAttribute) {
            
            containers[containers.count - 1].attributes.append(attribute)
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
    
    final class Container {
        
        var attributes: [NetlinkAttribute]
        
        init(attributes: [NetlinkAttribute] = []) {
            
            self.attributes = attributes
        }
        
        var data: Data {
            
            let size = attributes.reduce(0, { $0.0 + $0.1.paddedLength })
            
            let data = attributes.reduce(Data(capacity: size), { $0.0 + $0.1.paddedData })
            
            return data
        }
    }
}

// MARK: - KeyedEncodingContainerProtocol

internal extension NetlinkAttributeEncoder.Encoder {
    
    final class KeyedContainer <K : CodingKey> : KeyedEncodingContainerProtocol {
        
        typealias Key = K
        
        /// A reference to the encoder we're writing to.
        let encoder: NetlinkAttributeEncoder.Encoder
        
        /// The path of coding keys taken to get to this point in encoding.
        let codingPath: [CodingKey]
        
        init(referencing encoder: NetlinkAttributeEncoder.Encoder, codingPath: [CodingKey]) {
            
            self.encoder = encoder
            self.codingPath = codingPath
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
            
            let data: Data
            
            if let dataValue = value as? Data {
                
                data = dataValue
                
            } else {
                
                // encode
                
                try value.encode(to: self.encoder)
            }
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
            
            let type = try encoder.attributeType(for: key)
            encoder.stack.append(NetlinkAttribute(type: type, payload: value.attributeData))
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
