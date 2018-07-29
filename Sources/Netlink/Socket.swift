//
//  Socket.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/6/18.
//

#if os(Linux)
import Glibc
#elseif os(macOS)
import Darwin.C
#endif

import Foundation
import CLinuxWLAN

public final class NetlinkSocket {
    
    // MARK: - Properties
    
    public let netlinkProtocol: NetlinkSocketProtocol
    
    internal let internalSocket: CInt
    
    // MARK: - Initialization
    
    deinit {
        
        close(internalSocket)
    }
    
    public init(_ netlinkProtocol: NetlinkSocketProtocol, group: Int32 = 0) throws {
        
        // open socket
        let fileDescriptor = socket(PF_NETLINK, SOCK_RAW, netlinkProtocol.rawValue)
        
        guard fileDescriptor >= 0
            else { throw POSIXError.fromErrno! }
        
        var address = sockaddr_nl(nl_family: __kernel_sa_family_t(AF_NETLINK),
                                  nl_pad: UInt16(),
                                  nl_pid: __u32(getpid()),
                                  nl_groups: __u32(bitPattern: group))
        
        // initialize socket
        self.internalSocket = fileDescriptor
        self.netlinkProtocol = netlinkProtocol
        
        // bind socket
        guard withUnsafePointer(to: &address, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1, {
                bind(internalSocket, $0, socklen_t(MemoryLayout<sockaddr_nl>.size))
            })
        }) >= 0 else { throw POSIXError.fromErrno! }
    }
    
    // MARK: - Methods
    
    public func subscribe(to group: NetlinkGenericMulticastGroupIdentifier) throws {
        
        var groupValue = group.rawValue
        
        guard withUnsafePointer(to: &groupValue, { (pointer: UnsafePointer<CInt>) in
            setsockopt(internalSocket,
                       SOL_NETLINK,
                       NETLINK_ADD_MEMBERSHIP,
                       UnsafeRawPointer(pointer),
                       socklen_t(MemoryLayout<CInt>.size))
        }) == 0 else { throw POSIXError.fromErrno! }
    }
    
    public func unsubscribe(from group: NetlinkGenericMulticastGroupIdentifier) throws {
        
        var groupValue = group.rawValue
        
        guard withUnsafePointer(to: &groupValue, { (pointer: UnsafePointer<CInt>) in
            setsockopt(internalSocket,
                       SOL_NETLINK,
                       NETLINK_DROP_MEMBERSHIP,
                       UnsafeRawPointer(pointer),
                       socklen_t(MemoryLayout<CInt>.size))
        }) == 0 else { throw POSIXError.fromErrno! }
    }
    
    public func send(_ data: Data) throws {
        
        var address = sockaddr_nl(nl_family: __kernel_sa_family_t(AF_NETLINK),
                                  nl_pad: 0,
                                  nl_pid: 0,
                                  nl_groups: 0)
        
        let sentBytes = withUnsafePointer(to: &address, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1, { (socketPointer) in
                data.withUnsafeBytes { (dataPointer: UnsafePointer<UInt8>) in
                    sendto(internalSocket, UnsafeRawPointer(dataPointer), data.count, 0, socketPointer, socklen_t(MemoryLayout<sockaddr_nl>.size))
                }
            })
        })
        
        guard sentBytes >= 0
            else { throw POSIXError.fromErrno! }
        
        guard sentBytes == data.count
            else { throw NetlinkSocketError.invalidSentBytes(sentBytes) }
    }
    
    public func recieve <T: NetlinkMessageProtocol> (_ message: T.Type) throws -> [T] {
        
        let data = try recieve()
        
        if let errorMessages = try? NetlinkErrorMessage.from(data: data),
            let errorMessage = errorMessages.first {
            
            if let posixError = errorMessage.error {
                
                throw posixError
                
            } else {
                
                throw errorMessage
            }
            
        } else if let messages = try? T.from(data: data) {
            
            return messages
            
        } else {
            
            throw NetlinkSocketError.invalidData(data)
        }
    }
    
    public func recieve() throws -> Data {
        
        let chunkSize = Int(getpagesize())
        
        var readData = Data()
        var chunk = Data()
        repeat {
            chunk = try recieveChunk(size: chunkSize)
            readData.append(chunk)
        } while chunk.count == chunkSize // keep reading
        
        return readData
    }
    
    internal func recieveChunk(size: Int, flags: CInt = 0) throws -> Data {
        
        var data = Data(count: size)
        
        let recievedBytes = data.withUnsafeMutableBytes { (dataPointer: UnsafeMutablePointer<UInt8>) in
            recv(internalSocket, UnsafeMutableRawPointer(dataPointer), size, flags)
        }
        
        guard recievedBytes >= 0
            else { throw POSIXError.fromErrno! }
        
        return Data(data.prefix(recievedBytes))
    }
}

// MARK: - Supporting Types

public enum NetlinkSocketError: Error {
    
    case invalidProtocol
    case invalidSentBytes(Int)
    case invalidData(Data)
}
