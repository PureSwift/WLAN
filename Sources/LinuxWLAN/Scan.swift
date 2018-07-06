//
//  Scan.swift
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
import CSwiftLinuxWLAN

public extension LinuxWLANManager {
    
    /**
     Scans for networks.
     
     If ssid parameter is present, a directed scan will be performed by the interface, otherwise a broadcast scan will be performed. This method will block for the duration of the scan.
     
     - Parameter ssid: The SSID for which to scan.
     - Parameter interface: The network interface.
     */
    public func scan(with ssid: SSID? = nil, for interface: WLANInterface) throws -> [WLANNetwork] {
        
        try startScanning(for: interface.name)
        
        let duration: TimeInterval = 5.0
        let end = Date() + duration
        
        var isFinished = false
        repeat {
            sleep(1)
            isFinished = try isScanFinished(for: interface.name)
        }
            while Date() < end && isFinished == false
        
        // only parse scan results if ready
        guard isFinished else { throw POSIXError(code: .ETIMEDOUT) }
        
        return []
    }
    
    internal func startScanning(for interface: String) throws {
        
        var request = iwreq()
        request.setInterfaceName(interface)
        
        guard IOControl(internalSocket, SIOCSIWSCAN, &request) != -1
            else { throw POSIXError.fromErrno! }
    }
    
    internal func isScanFinished(for interface: String) throws -> Bool {
        
        var fakeBuffer: UInt8 = 0x00
        
        return try withUnsafeMutablePointer(to: &fakeBuffer) { (pointer: UnsafeMutablePointer<UInt8>) in
            
            var request = iwreq()
            request.setInterfaceName(interface)
            request.u.data.pointer = UnsafeMutableRawPointer(pointer)
            request.u.data.length = 0
            request.u.data.flags = 0
            
            guard IOControl(internalSocket, SIOCSIWSCAN, &request) != -1 else {
                
                let error = POSIXError.fromErrno!
                
                switch error.code {
                case .E2BIG: // Data is ready, but not enough space,
                    return true
                case .EAGAIN: // Data is not ready
                    return false
                default:
                    throw error
                }
            }
            
            // other cases with no error, data is ready
            return true
        }
    }
}
