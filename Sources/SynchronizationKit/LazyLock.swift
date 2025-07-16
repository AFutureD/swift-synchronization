//
//  LazyLock.swift
//  swift-lazy
//
//  Created by Huanan on 2025/7/16.
//

#if os(iOS) || os(watchOS) || os(tvOS)
import os.lock
#endif


public struct LazyLockedValue<Value>: @unchecked Sendable {

#if os(iOS) || os(watchOS) || os(tvOS)
    typealias LockPrimitive = OSAllocatedUnfairLock
#else
    typealias LockPrimitive = NIOLockedValueBox
#endif


    internal let inner: LockPrimitive<Value>

    public init(_ value: Value) where Value: Sendable {
#if os(iOS) || os(watchOS) || os(tvOS)
        self.inner = .init(initialState: value)
#else
        self.inner = .init(value)
#endif
    }

    public init(_ value: Value) {
#if os(iOS) || os(watchOS) || os(tvOS)
        self.inner = .init(uncheckedState: value)
#else
        self.inner = .init(value)
#endif
    }

    public func withLock<T>(_ mutate: @Sendable (inout Value) throws -> T) rethrows -> T where T : Sendable {
#if os(iOS) || os(watchOS) || os(tvOS)
        try self.inner.withLock(mutate)
#else
        try self.inner.withLockedValue(mutate)
#endif
    }

    public func withLock<T>(_ mutate: (inout Value) throws -> T) rethrows -> T {
#if os(iOS) || os(watchOS) || os(tvOS)
        try self.inner.withLockUnchecked(mutate)
#else
        try self.inner.withLockedValue(mutate)
#endif
    }
}


public struct LazyLock: @unchecked Sendable {
#if os(iOS) || os(watchOS) || os(tvOS)
    typealias LockPrimitive = OSAllocatedUnfairLock<()>
#else
    typealias LockPrimitive = NIOLock
#endif

    internal let inner: LockPrimitive

    public init() {
#if os(iOS) || os(watchOS) || os(tvOS)
        self.inner = .init()
#else
        self.inner = .init()
#endif
    }

    public func lock() {
        self.inner.lock()
    }

    public func unlock() {
        self.inner.unlock()
    }
}
