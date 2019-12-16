//
//  PathVariableProvider.swift
//  RestingKit
//
//  Created by Moray Baruh on 20.11.2019.
//

import Foundation

public protocol PathVariableProvider {
    var variables: [String: Any] { get }
}

public class RestingPathVariableProvider: PathVariableProvider {
    private(set) var providers: [String: () -> (Any?)]

    public var variables: [String: Any] { providers.compactMapValues { $0() } }

    public init(providers: [String: () -> (Any?)] = [:]) {
        self.providers = providers
    }

    public func addVariable(key: String, value: Any) {
        providers[key] = { value }
    }

    public func addVariable(key: String, provider: @escaping () -> Any?) {
        providers[key] = provider
    }

    public func removeVariable(for key: String) {
        providers.removeValue(forKey: key)
    }
}
