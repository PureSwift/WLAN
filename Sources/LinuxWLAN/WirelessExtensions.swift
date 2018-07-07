//
//  WirelessExtensions.swift
//  LinuxWLAN
//
//  Created by Alsey Coleman Miller on 7/5/18.
//

#if os(Linux)
import Glibc
#elseif os(macOS) || os(iOS)
import Darwin.C
#endif

import Foundation
import WLAN
import CLinuxWLAN

/// Linux Wireless Extensions API
public final class LinuxWirelessExtensions {
    
    // MARK: - Properties
    
    /// Socket handle to kernel network interfaces subsystem.
    internal let internalSocket: CInt
    
    // MARK: - Initialization
    
    public init() throws {
        
        let netSocket = socket(AF_INET, SOCK_STREAM, 0)
        
        guard netSocket >= 0 else { throw POSIXError.fromErrno! }
        
        self.internalSocket = netSocket
    }
    
    deinit {
        
        close(internalSocket)
    }
    
    // MARK: - Accessors
    
    /// Returns the default Wi-Fi interface.
    public var interface: WLANInterface? { return interfaces.first }
    
    /**
     Returns all available Wi-Fi interfaces.
     
     - Returns: An array of `WLANInterface`, representing all of the available Wi-Fi interfaces in the system.
     */
    public var interfaces: [WLANInterface] {
        
        return try! wirelessInterfaces()
    }
    
    // MARK: - Methods
    
    internal func wirelessInterfaces() throws -> [WLANInterface] {
        
        let networkInterfaces = try NetworkInterface.interfaces()
        
        var wlanInterfaces = [WLANInterface]()
        
        for interface in networkInterfaces {
            
            let wlanInterface = WLANInterface(name: interface.name)
            
            do { let _ = try name(for: wlanInterface) }
            catch { continue }
            
            wlanInterfaces.append(wlanInterface)
        }
        
        return wlanInterfaces
    }
    
    public func name(for interface: WLANInterface) throws -> String {
        
        typealias Name = (Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8)
        
        var request = iwreq()
        request.setInterfaceName(interface.name)
        
        guard IOControl(internalSocket, SIOCGIWNAME, &request) != -1
            else { throw POSIXError.fromErrno! }
        
        var nameBuffer = UnsafeMutablePointer<Name>.allocate(capacity: 1)
        
        nameBuffer.pointee = request.u.name
        
        defer { nameBuffer.deallocate(capacity: 1) }
        
        return nameBuffer.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Name>.size, { String(cString: $0) })
    }
    
    public func version(for interface: WLANInterface) throws -> UInt8 {
        
        var result = [iw_range](repeating: iw_range(), count: 2)
        try result.withUnsafeMutableBytes {
            
            var request = iwreq()
            request.setInterfaceName(interface.name)
            
            request.u.data.pointer = UnsafeMutableRawPointer($0.baseAddress!)
            request.u.data.length = __u16(MemoryLayout<iw_range>.size * 2)
            request.u.data.flags = 0
            
            guard IOControl(internalSocket, SIOCGIWNAME, &request) != -1
                else { throw POSIXError.fromErrno! }
        }
        
        return result[0].we_version_compiled
    }
    
    /**
     Scans for networks.
     
     If ssid parameter is present, a directed scan will be performed by the interface, otherwise a broadcast scan will be performed. This method will block for the duration of the scan.
     
     - Parameter ssid: The SSID for which to scan.
     - Parameter interface: The network interface.
     */
    public func scan(for interface: WLANInterface) throws -> [WLANNetwork] {
        
        try startScanning(for: interface)
        
        let duration: TimeInterval = 5.0
        let end = Date() + duration
        
        var isFinished = false
        
        repeat {
            sleep(1)
            isFinished = try isScanFinished(for: interface)
        }
            
            while Date() < end && isFinished == false
        
        // only parse scan results if ready
        guard isFinished else { throw POSIXError(code: .ETIMEDOUT) }
        
        return try scanResults(for: interface)
    }
    
    internal func startScanning(for interface: WLANInterface) throws {
        
        var request = iwreq()
        request.setInterfaceName(interface.name)
        
        guard IOControl(internalSocket, SIOCSIWSCAN, &request) != -1
            else { throw POSIXError.fromErrno! }
    }
    
    internal func isScanFinished(for interface: WLANInterface) throws -> Bool {
        
        var fakeBuffer: UInt8 = 0x00
        
        return try withUnsafeMutablePointer(to: &fakeBuffer) { (pointer: UnsafeMutablePointer<UInt8>) in
            
            var request = iwreq()
            request.setInterfaceName(interface.name)
            request.u.data.pointer = UnsafeMutableRawPointer(pointer)
            request.u.data.length = 0
            request.u.data.flags = 0
            
            guard IOControl(internalSocket, SIOCSIWSCAN, &request) != -1 else {
                
                let error = POSIXError.fromErrno!
                
                switch error.code {
                case .E2BIG: // Data is ready, but not enough space,
                    return true
                case .EAGAIN,
                     .EBUSY: // Data is not ready
                    return false
                default:
                    throw error
                }
            }
            
            // other cases with no error, data is ready
            return true
        }
    }
    
    internal func scanResults(for interface: WLANInterface) throws -> [WLANNetwork] {
        
        var networks = [WLANNetwork]()
        
        var bufferLength = Int(IW_SCAN_MAX_DATA)
        var scanDataBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferLength)
        defer { scanDataBuffer.deallocate(capacity: bufferLength) }
        
        var request = iwreq()
        request.setInterfaceName(interface.name)
        request.u.data.pointer = UnsafeMutableRawPointer(scanDataBuffer)
        request.u.data.length = __u16(bufferLength)
        request.u.data.flags = 0
        
        // try getting data
        while IOControl(internalSocket, SIOCSIWSCAN, &request) != -1 {
            
            let error = POSIXError.fromErrno!
            
            switch error.code {
                
            case .E2BIG:
                
                // grow buffer
                bufferLength += Int(IW_SCAN_MAX_DATA)
                scanDataBuffer.deallocate(capacity: bufferLength)
                scanDataBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferLength)
                request.u.data.length = __u16(bufferLength)
                
                continue
                
            default:
                throw error
            }
        }
        
        let scanData = Data(bytes: UnsafeRawPointer(request.u.data.pointer),
                            count: Int(request.u.data.length))
        
        //let version = try wirelessExtensionVersion(for: interface)
        
        print(Array(scanData))
        
        // parse data
        
        return networks
    }
}

// MARK: - Linux Support

internal extension iwreq {
    
    mutating func setInterfaceName(_ name: String) {
        
        name.withCString {
            self.ifr_ifrn.ifrn_name = unsafeBitCast($0, to: UnsafeMutablePointer<(Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8)>.self).pointee
        }
    }
}

#if os(Linux)

internal let SOCK_RAW = CInt(Glibc.SOCK_RAW.rawValue)

internal let SOCK_STREAM = CInt(Glibc.SOCK_STREAM.rawValue)

internal typealias sa_family_t = Glibc.sa_family_t

#elseif os(macOS)

internal var AF_PACKET: CInt { fatalError("\(#function) is only availible on Linux") }

#endif
