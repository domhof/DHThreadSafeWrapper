//
//  DHThreadSafeWrapper.swift
//  DHThreadSafeWrapper
//
//  Created by Dominik Hofer on 09.03.19.
//  Copyright © 2019 Dominik Hofer. All rights reserved.
//

import Foundation

/// Combines a value with a dispatch queue. The dispatch queue is used to access the value concurrently.
public class ThreadSafe<Type> {
    private var value_: Type
    private let dispatchQueue: DispatchQueue
    
    /// Creates an instance with the given value and a concurrent dispatch queue.
    ///
    /// - Parameters:
    ///   - value: The value that should be concurrently accessible.
    ///   - label: The label that should be used for the underlying dispatch queue. The default is "com.dominikhofer.DHThreadSafeWrapper".
    public convenience init(_ value: Type, label: String = "com.dominikhofer.DHThreadSafeWrapper") {
        self.init(value, dispatchQueue: DispatchQueue(label: label, attributes: .concurrent))
    }
    
    /// Creates an instance with the given value and a concurrent dispatch queue.
    ///
    /// - Parameters:
    ///   - value: The value that should be concurrently accessible.
    ///   - label: The label that should be used for the underlying dispatch queue. The default is "com.dominikhofer.DHThreadSafeWrapper".
    ///   - qos: The quality of service class the dispatch queue should work on.
    public convenience init(_ value: Type, label: String = "com.dominikhofer.DHThreadSafeWrapper", qos: DispatchQoS) {
        self.init(value, dispatchQueue: DispatchQueue(label: label, qos: qos, attributes: .concurrent))
    }
    
    /// Creates an instance with the given value and dispatch queue.
    ///
    /// - Parameters:
    ///   - value: The value that should be concurrently accessible.
    ///   - accessQueue: The dispatch queue that should be used to access the value.
    public init(_ value: Type, dispatchQueue: DispatchQueue) {
        self.value_ = value
        self.dispatchQueue = dispatchQueue
    }
    
    /// Get the value synchronously.
    public var value: Type {
        get {
            var value_: Type!
            syncRead { value_ = $0 }
            return value_
        }
    }
    
    /// Read the value synchronously.
    ///
    /// - Parameter block: The block in which the value will be accessed.
    /// - Throws: Rethrows errors from the block.
    public func syncRead(_ block: @escaping (Type) throws -> ()) rethrows {
        try dispatchQueue.sync() {
            try block(self.value_)
        }
    }
    
    /// Write the value synchronously.
    ///
    /// - Parameter block: The block in which the value will be accessed.
    /// - Throws: Rethrows errors from the block.
    public func syncWrite(_ block: @escaping (inout Type) throws -> ()) rethrows {
        try dispatchQueue.sync(flags: .barrier) {
            try block(&self.value_)
        }
    }
    
    /// Read the value asynchronously.
    ///
    /// - Parameter block: The block in which the value will be accessed.
    public func asyncRead(_ block: @escaping (Type) -> ()) {
        dispatchQueue.async() {
            block(self.value_)
        }
    }
    
    /// Write the value asynchronously.
    ///
    /// - Parameter block: The block in which the value will be accessed.
    public func asyncWrite(_ block: @escaping (inout Type) -> ()) {
        dispatchQueue.async(flags: .barrier) {
            block(&self.value_)
        }
    }
    
    /// Write the value after some time.
    ///
    /// - Parameters:
    ///   - delay: The time to wait before writing the value.
    ///   - block: The block in which the value will be accessed.
    public func writeAfter(after delay: Double, _ block: @escaping (inout Type) -> ()) -> DispatchWorkItem {
        let workItem = DispatchWorkItem {
            block(&self.value_)
        }
        
        dispatchQueue.asyncAfter(deadline: .now() + delay, flags: .barrier, execute: {
            if !workItem.isCancelled {
                workItem.perform()
            }
        })
        return workItem
    }
}
