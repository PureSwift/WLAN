//
//  WirelessExtensions.swift
//  LinuxWLAN
//
//  Created by Alsey Coleman Miller on 7/5/18.
//

#if os(Linux)
import Glibc
#elseif canImport(Darwin)
import Darwin.C
#endif

import Foundation
import WLAN
import CLinuxWLAN
import SystemPackage

/// Linux Wireless Extensions API
public final class LinuxWirelessExtensions {
    
    // MARK: - Properties
    
    /// Socket handle to kernel network interfaces subsystem.
    internal let fileDescriptor: FileDescriptor
    
    // MARK: - Initialization
    
    public init() throws {
        let rawValue = socket(AF_INET, SOCK_STREAM, 0)
        guard rawValue >= 0 else { throw Errno(rawValue: errno) }
        self.fileDescriptor = FileDescriptor(rawValue: rawValue)
        #if os(Linux)
        throw POSIXError(.EBADEXEC)
        #endif
    }
    
    deinit {
        try? fileDescriptor.close()
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
        #if os(Linux)
        typealias Name = (Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8)
        
        var request = iwreq()
        request.setInterfaceName(interface.name)
        
        guard ioctl(fileDescriptor.rawValue, .init(SIOCGIWNAME), &request) != -1
            else { throw Errno(rawValue: errno) }
        
        let nameBuffer = UnsafeMutablePointer<Name>.allocate(capacity: 1)
        nameBuffer.pointee = request.u.name
        defer { nameBuffer.deallocate() }
        return nameBuffer.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Name>.size, { String(cString: $0) })
        #else
        fatalError("Linux only")
        #endif
    }
    
    public func version(for interface: WLANInterface) throws -> UInt8 {
        #if os(Linux)
        var result = [iw_range](repeating: iw_range(), count: 2)
        try result.withUnsafeMutableBytes {
            
            var request = iwreq()
            request.setInterfaceName(interface.name)
            
            request.u.data.pointer = UnsafeMutableRawPointer($0.baseAddress!)
            request.u.data.length = numericCast(MemoryLayout<iw_range>.size * 2)
            request.u.data.flags = 0
            
            guard ioctl(fileDescriptor.rawValue, .init(SIOCGIWNAME), &request) != -1
                else { throw Errno(rawValue: errno) }
        }
        return result[0].we_version_compiled
        #else
        fatalError("Linux only")
        #endif
    }
    
    #if os(Linux)
    /**
     Scans for networks.
     
     If ssid parameter is present, a directed scan will be performed by the interface, otherwise a broadcast scan will be performed. This method will block for the duration of the scan.
     
     - Parameter ssid: The SSID for which to scan.
     - Parameter interface: The network interface.
     */
    public func scan(for interface: WLANInterface) throws -> [WLANNetwork] {
        
        try startScanning(for: interface)
        
        let duration: Double = 5.0
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
        
        guard ioctl(fileDescriptor.rawValue, .init(SIOCSIWSCAN), &request) != -1
            else { throw Errno(rawValue: errno) }
    }
    
    internal func isScanFinished(for interface: WLANInterface) throws -> Bool {
        
        var fakeBuffer: UInt8 = 0x00
        
        return try withUnsafeMutablePointer(to: &fakeBuffer) { (pointer: UnsafeMutablePointer<UInt8>) in
            
            var request = iwreq()
            request.setInterfaceName(interface.name)
            request.u.data.pointer = UnsafeMutableRawPointer(pointer)
            request.u.data.length = 0
            request.u.data.flags = 0
            
            guard ioctl(fileDescriptor.rawValue, .init(SIOCSIWSCAN), &request) != -1 else {
                
                let error = Errno(rawValue: errno)
                
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
        
        let networks = [WLANNetwork]()
        
        var bufferLength = Int(IW_SCAN_MAX_DATA)
        var scanDataBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferLength)
        defer { scanDataBuffer.deallocate() }
        
        var request = iwreq()
        request.setInterfaceName(interface.name)
        request.u.data.pointer = UnsafeMutableRawPointer(scanDataBuffer)
        request.u.data.length = numericCast(bufferLength)
        request.u.data.flags = 0
        
        // try getting data
        while ioctl(fileDescriptor.rawValue, .init(SIOCSIWSCAN), &request) != -1 {
            
            let error = Errno(rawValue: errno)
            
            switch error.code {
                
            case .E2BIG:
                
                // grow buffer
                bufferLength += Int(IW_SCAN_MAX_DATA)
                scanDataBuffer.deallocate()
                scanDataBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferLength)
                request.u.data.length = numericCast(bufferLength)
                
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
    #endif
}

// MARK: - Linux Support

internal extension iwreq {
    
    mutating func setInterfaceName(_ name: String) {
        typealias CString = (Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8)
        name.withCString {
            $0.withMemoryRebound(to: CString.self, capacity: 1) {
                self.ifr_ifrn.ifrn_name = $0.pointee
            }
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
