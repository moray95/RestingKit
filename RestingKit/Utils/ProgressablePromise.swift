//
//  ProgressablePromise.swift
//  RestingKit
//
//  Created by Moray on 3/16/19.
//

import Foundation
import PromiseKit

/// A progress handler, called upon progress changes on a task.
public typealias ProgressHandler = (Progress) -> Void

private protocol AnyProgressablePromise: AnyObject {
    var children: [AnyProgressablePromise] { get set }

    func progress(_ progress: Progress)
}

/// A  wrapper around PromiseKit's Promise class that supports progress callbacks.
public class ProgressablePromise<T>: AnyProgressablePromise {
    /// The underlaying promise.
    public let promise: Promise<T>

    private var progressHandlers = [ProgressHandler]()
    private weak var parent: AnyProgressablePromise?
    fileprivate var children = [AnyProgressablePromise]()
    private var this: ProgressablePromise<T>?

    ///
    /// Creates a `ProgressablePromise` from the given promise.
    /// Progress handlers are not suported when using this initlializer.
    ///
    /// - parameter promise: The promise to wrap.
    ///
    public convenience init(promise: Promise<T>) {
        self.init(promise: promise, parent: nil)
    }

    ///
    /// Creates a new `ProgressablePromise` using the given resolver.
    ///
    /// - parameter resolver: The callback that perform the expected task.
    ///
    /// The callback is given two parameters: a `Resolver<T>` and a `ProgressHandler`. The callback is expected
    /// to perform a task, while calling the progress handler on a regular basis and finally resolve the promise.
    ///
    public convenience init(_ resolver: (Resolver<T>, @escaping ProgressHandler) throws -> Void) {
        let (promise, promiseResolver) = Promise<T>.pending()
        self.init(promise: promise)
        do {
            try resolver(promiseResolver, self.progress(_:))
        } catch {
            promiseResolver.reject(error)
        }
    }

    private init(promise: Promise<T>, parent: AnyProgressablePromise?) {
        self.promise = promise
        self.parent = parent
        parent?.children.append(self)
        self.this = self
        promise.ensure {
            self.this = nil
        }.cauterize()
    }

    ///  Assign a progress handler to the promise that will be called each time an update to the progress is made.
    public func progress(_ handler: @escaping (Progress) -> Void) -> Promise<T> {
        progressHandlers.append(handler)
        return promise
    }

    internal func progress(_ progress: Progress) {
        progressHandlers.forEach { $0(progress) }
        children.forEach { $0.progress(progress) }
    }

    func map<U>(_ transform: @escaping (T) throws -> U) -> ProgressablePromise<U> {
        return ProgressablePromise<U>(promise: promise.map(transform), parent: self)
    }

    func then<U>(_ body: @escaping(T) throws -> ProgressablePromise<U>) -> ProgressablePromise<U> {
        let (promise, resolver) = Promise<U>.pending()
        let progressable = ProgressablePromise<U>(promise: promise, parent: self)
        self.promise.then { (value: T) -> Promise<U> in
            let newProgressable = try body(value)
            newProgressable.children.append(progressable)
            progressable.parent = newProgressable
            newProgressable.parent = self
            return newProgressable.promise
        }.done {
            resolver.fulfill($0)
        }.catch {
            resolver.reject($0)
        }

        return progressable
    }

    func get(_ body: @escaping (T) throws -> Void) -> ProgressablePromise<T> {
        return ProgressablePromise(promise: promise.get(body), parent: self)
    }

    func ensure(_ body: @escaping () -> Void) -> ProgressablePromise<T> {
        return ProgressablePromise(promise: promise.ensure(body), parent: self)
    }
}

extension Promise {
    func asProgressable() -> ProgressablePromise<T> {
        return ProgressablePromise(promise: self)
    }
}
