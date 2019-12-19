//
//  HeaderProvider.swift
//  RestingKit
//
//  Created by Moray Baruh on 20.11.2019.
//

import Foundation

/// An interface to provide globally available headers  to `RestingRequestConverter`.
public protocol HeaderProvider {
    /// The headers to add the request.
    var headers: [String: String] { get }
}

/// A default implementation of `HeaderProvider` supporting dynamic header provisioning.
public class RestingHeaderProvider: HeaderProvider {
    /// Callbacks that generates header value for a given header name.
    private(set) var providers: [String: () -> (String?)]

    /// The headers to add to a request on a given time. Generated from `providers`,
    /// discarting `nil` values.
    public var headers: [String: String] { providers.compactMapValues { $0() } }

    ///
    /// Creates a new `RestingHeaderProvider` with the given header callbacks.
    ///
    /// - parameter providers: The callbacks to generate headers for requests. Keys indicate the name and the
    ///                        return of the callback the value of the header to add. `nil` values are discarted.
    public init(providers: [String: () -> (String?)] = [:]) {
        self.providers = providers
    }

    ///
    /// Adds a static header value for the given key.
    ///
    /// - parameter key: The name of the header.
    /// - parameter value: The value of the header.
    ///
    /// Adding a header to an existing overrides the previous one.
    public func addHeader(key: String, value: String) {
        providers[key] = { value }
    }

    ///
    /// Adds a dynamic header value for the given key.
    ///
    /// Adding a header to an existing overrides the previous one.
    ///
    /// - parameter key: The name of the header.
    /// - parameter provider: The provider to call for the header value. `nil` values are discarted.
    ///
    public func addHeader(key: String, provider: @escaping () -> String?) {
        providers[key] = provider
    }

    ///
    /// Removes a header added for the given key.
    ///
    /// - parameter key: The name of the header to remove.
    ///
    public func removeHeader(for key: String) {
        providers.removeValue(forKey: key)
    }
}
