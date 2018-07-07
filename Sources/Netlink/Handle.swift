//
//  Handle.swift
//  Netlink
//
//  Created by Alsey Coleman Miller on 7/7/18.
//

// MARK: - Handle

/// A Swift class wrapper for a C object.
internal protocol Handle: class {
    
    associatedtype RawPointer: Equatable
    
    var rawPointer: RawPointer { get }
}

// MARK: - ManagedHandle

// For Swift 4
// internal protocol ManagedHandle: Handle where RawPointer == InternalPointer.RawPointer {

/// A Swift class wrapper for a C object that uses manual reference counting for memory management.
internal protocol ManagedHandle: Handle {
    
    associatedtype Unmanaged: UnmanagedPointer
    
    var managedPointer: ManagedPointer<Unmanaged> { get }
    
    init(_ managedPointer: ManagedPointer<Unmanaged>)
}

internal extension ManagedHandle where RawPointer == Unmanaged.RawPointer  {
    
    var unmanagedPointer: Unmanaged {
        
        @inline(__always)
        get { return managedPointer.unmanagedPointer }
    }
    
    var rawPointer: RawPointer {
        
        @inline(__always)
        get { return unmanagedPointer.rawPointer }
    }
}

// MARK: - Managed / Unmanaged Pointer

/// A type for propagating an unmanaged C object reference.
/// When you use this type, you become partially responsible for keeping the object alive.
internal protocol UnmanagedPointer {
    
    associatedtype RawPointer
    
    init(_ rawPointer: RawPointer)
    
    var rawPointer: RawPointer { get }
    
    func retain()
    
    func release()
}

/// Generic class for using C objects with manual reference count.
internal final class ManagedPointer <Unmanaged: UnmanagedPointer> {
    
    let unmanagedPointer: Unmanaged
    
    deinit {
        
        unmanagedPointer.release()
    }
    
    init(_ unmanagedPointer: Unmanaged) {
        
        self.unmanagedPointer = unmanagedPointer
    }
}
