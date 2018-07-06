//
//  MessageHeader.swift
//  WLAN
//
//  Created by Alsey Coleman Miller on 7/6/18.
//
//

#if os(Linux)
    import Glibc
#elseif os(macOS) || os(iOS)
    import Darwin.C
#endif

import Foundation
import CSwiftLinuxWLAN
/*
 The Netlink message header is shown below.
 
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 |                          Length                             |
 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 |            Type              |           Flags              |
 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 |                      Sequence Number                        |
 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 |                      Process ID (PID)                       |
 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 
 The fields in the header are:
 
 Length: 32 bits
 The length of the message in bytes, including the header.
 
 Type: 16 bits
 This field describes the message content.
 It can be one of the standard message types:
 NLMSG_NOOP  Message is ignored.
 NLMSG_ERROR The message signals an error and the payload
 contains a nlmsgerr structure.  This can be looked
 at as a NACK and typically it is from FEC to CPC.
 NLMSG_DONE  Message terminates a multipart message.
 
 Individual IP services specify more message types, e.g.,
 NETLINK_ROUTE service specifies several types, such as RTM_NEWLINK,
 RTM_DELLINK, RTM_GETLINK, RTM_NEWADDR, RTM_DELADDR, RTM_NEWROUTE,
 RTM_DELROUTE, etc.
 
 Flags: 16 bits
 The standard flag bits used in Netlink are
 NLM_F_REQUEST   Must be set on all request messages (typically
 from user space to kernel space)
 NLM_F_MULTI     Indicates the message is part of a multipart
 message terminated by NLMSG_DONE
 NLM_F_ACK       Request for an acknowledgment on success.
 Typical direction of request is from user
 space (CPC) to kernel space (FEC).
 NLM_F_ECHO      Echo this request.  Typical direction of
 request is from user space (CPC) to kernel
 space (FEC).
 
 Additional flag bits for GET requests on config information in
 the FEC.
 NLM_F_ROOT     Return the complete table instead of a
 single entry.
 NLM_F_MATCH    Return all entries matching criteria passed in
 message content.
 NLM_F_ATOMIC   Return an atomic snapshot of the table being
 referenced.  This may require special
 privileges because it has the potential to
 interrupt service in the FE for a longer time.
 
 Convenience macros for flag bits:
 NLM_F_DUMP     This is NLM_F_ROOT or'ed with NLM_F_MATCH
 Additional flag bits for NEW requests
 NLM_F_REPLACE   Replace existing matching config object with
 this request.
 NLM_F_EXCL      Don't replace the config object if it already
 exists.
 NLM_F_CREATE    Create config object if it doesn't already
 exist.
 NLM_F_APPEND    Add to the end of the object list.
 
 For those familiar with BSDish use of such operations in route
 sockets, the equivalent translations are:
 
 - BSD ADD operation equates to NLM_F_CREATE or-ed
 with NLM_F_EXCL
 - BSD CHANGE operation equates to NLM_F_REPLACE
 - BSD Check operation equates to NLM_F_EXCL
 - BSD APPEND equivalent is actually mapped to
 NLM_F_CREATE
 
 Sequence Number: 32 bits
 The sequence number of the message.
 
 Process ID (PID): 32 bits
 The PID of the process sending the message.  The PID is used by the
 kernel to multiplex to the correct sockets.  A PID of zero is used
 when sending messages to user space from the kernel.
 */

/**
 Netlink Message Header
 
 Netlink messages consist of a byte stream with one or multiple
 Netlink headers and an associated payload.  If the payload is too big
 to fit into a single message it, can be split over multiple Netlink
 messages, collectively called a multipart message.  For multipart
 messages, the first and all following headers have the NLM_F_MULTI
 Netlink header flag set, except for the last header which has the
 Netlink header type NLMSG_DONE.
 */
public struct NetlinkMessageHeader {
    
    /**
     Length: 32 bits
     
     The length of the message in bytes, including the header.
     */
    public var length: UInt32
    
    /**
     Type: 16 bits
     
     This field describes the message content.
     It can be one of the standard message types:
     * NLMSG_NOOP  Message is ignored.
     * NLMSG_ERROR The message signals an error and the payload
     contains a nlmsgerr structure.  This can be looked
     at as a NACK and typically it is from FEC to CPC.
     * NLMSG_DONE  Message terminates a multipart message.
     */
    
    public var type: NetlinkMessageType
}
