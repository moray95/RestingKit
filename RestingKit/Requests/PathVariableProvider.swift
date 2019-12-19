//
//  PathVariableProvider.swift
//  RestingKit
//
//  Created by Moray Baruh on 20.11.2019.
//

import Foundation

/// An interface to provide globally available path variables to `RestingRequestConverter`.
public protocol PathVariableProvider {
    /// The variables to provid e to the request.
    var variables: [String: Any] { get }
}

/// A default implementation of `HeaderProvider` supporting dynamic variable provisioning.
public class RestingPathVariableProvider: PathVariableProvider {
    /// Callbacks that generates a value for a given variable name.
    private(set) var providers: [String: () -> (Any?)]

    /// The varaibles to provide  to a request on a given time. Generated from `providers`,
    /// discarting `nil` values.
    public var variables: [String: Any] { providers.compactMapValues { $0() } }

    ///
    /// Creates a new `RestingPathVariableProvider` with the given variable callbacks.
    ///
    /// - parameter providers: The callbacks to generate variable values for requests. Keys indicate the name and the
    ///                        return of the callback the value of the variable to add. `nil` values are discarted.
    public init(providers: [String: () -> (Any?)] = [:]) {
        self.providers = providers
    }

    ///
    /// Adds a static variable value for the given key.
    ///
    /// - parameter key: The name of the variable.
    /// - parameter value: The value of the variable.
    ///
    /// Adding a variable to an existing overrides the previous one.
    public func addVariable(key: String, value: Any) {
        providers[key] = { value }
    }

    ///
    /// Adds a dynamic variable value for the given key.
    ///
    /// Adding a variable to an existing overrides the previous one.
    ///
    /// - parameter key: The name of the variable.
    /// - parameter provider: The provider to call for the varible  value. `nil` values are discarted.
    ///
    public func addVariable(key: String, provider: @escaping () -> Any?) {
        providers[key] = provider
    }

    ///
    /// Removes a variable added for the given key.
    ///
    /// - parameter key: The name of the variable to remove.
    ///
    public func removeVariable(for key: String) {
        providers.removeValue(forKey: key)
    }
}
