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

#if os(Linux) || Xcode
import CNetlink
import Netlink
#endif

public extension LinuxWLANManager {
    
    /**
     Scans for networks.
     
     If ssid parameter is present, a directed scan will be performed by the interface, otherwise a broadcast scan will be performed. This method will block for the duration of the scan.
     
     - Parameter ssid: The SSID for which to scan.
     - Parameter interface: The network interface.
     */
    public func scan(with ssid: SSID? = nil, for interface: WLANInterface) throws -> [WLANNetwork] {
        
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
    
    #if os(Linux) || Xcode
    internal func scanResults(for interface: WLANInterface) throws -> [WLANNetwork] {
        
        let interfaceIndex = try NetworkInterface.index(for: NetworkInterface(name: interface.name))
        
        // Open socket to kernel.
        // Create file descriptor and bind socket.
        let netlinkSocket = try NetlinkGenericSocket()
        
        let driverID = try netlinkSocket.resolve(name: .nl80211)  // Find the "nl80211" driver ID.
        
        // Create message
        let message = NetlinkMessage()
        
        // Setup which command to run.
        message.genericView.put(port: 0,
                                sequence: 0,
                                family: driverID,
                                headerLength: 0,
                                flags: NetlinkMessageFlag.Get.dump,
                                command: NetlinkGenericCommand.NL80211.getScanResults,
                                version: 0)
        
        // Add message attribute, specify which interface to use.
        try message.setValue(UInt32(interfaceIndex), for: NetlinkAttribute.NL80211.interfaceIndex)
        
        netlinkSocket
        
        var networks = [WLANNetwork]()
        
        
        return networks
    }
    #else
    internal func scanResults(for interface: WLANInterface) throws -> [WLANNetwork] {
        
        assertionFailure("Linux only API")
        return []
    }
    #endif
    
    /*
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
        
        //print(Array(scanData))
        
        //prepare_nl_message(channel->nl80211_id, NLM_F_REQUEST | NLM_F_DUMP | NLM_F_ACK, NL80211_CMD_GET_SCAN, channel)
        
        // parse data
        
        return networks
    }*/
}
