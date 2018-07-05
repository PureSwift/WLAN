//
//  Error.swift
//  WLAN
//
//  Created by Alsey Coleman Miller on 7/4/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

public enum WLANError: Error {
    
    /// Invalid interface specified.
    case invalidInterface(WLANInterface)
    
    /// Invalid network specified.
    case invalidNetwork(WLANNetwork)
}
