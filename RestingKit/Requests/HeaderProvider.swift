//
//  HeaderProvider.swift
//  RestingKit
//
//  Created by Moray Baruh on 20.11.2019.
//

import Foundation

public protocol HeaderProvider {
    var headers: [String: String] { get }
}

public class RestingHeaderProvider: HeaderProvider {
    private(set) var providers: [String: () -> (String?)]

    public var headers: [String: String] { providers.compactMapValues { $0() } }

    public init(providers: [String: () -> (String?)]) {
        self.providers = providers
    }

    public func addHeader(key: String, value: String) {
        providers[key] = { value }
    }

    public func addHeader(key: String, provider: @escaping () -> String?) {
        providers[key] = provider
    }

    public func removeHeader(for key: String) {
        providers.removeValue(forKey: key)
    }
}
