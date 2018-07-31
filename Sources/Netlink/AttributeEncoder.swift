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
        
        return encoder.data
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
        
        private(set) var data = Data()
        
        // MARK: - Initialization
        
        init(codingPath: [CodingKey] = [],
             userInfo: [CodingUserInfoKey : Any],
             log: Log?) {
            
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

// MARK: - Stack

fileprivate extension NetlinkAttributeEncoder.Encoder {
    
    fileprivate struct Stack {
        
        private(set) var containers = [Container]()
        
        fileprivate init() { }
        
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

fileprivate extension NetlinkAttributeEncoder.Encoder.Stack {
    
    enum Container {
        
        case attributes([NetlinkAttribute])
        case attribute(NetlinkAttribute)
    }
}
