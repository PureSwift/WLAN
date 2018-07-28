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
    
    @discardableResult
    public func send(_ data: Data) throws -> Int {
        
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
        
        return sentBytes
    }
    
    public func recieve <T: NetlinkMessageProtocol> (_ message: T.Type) throws -> [T] {
        
        let data = try recieve()
        
        if let errorMessages = try? NetlinkErrorMessage.from(data: data),
            let errorMessage = errorMessages.first {
            
            throw errorMessage.error
            
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
    case invalidData(Data)
}

// MARK: - Linux Support

#if os(Linux)
    
internal let SOCK_RAW = CInt(Glibc.SOCK_RAW.rawValue)

#endif

internal let AF_NETLINK: CInt = 16

internal let PF_NETLINK: CInt = 16
