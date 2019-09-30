//
//  HTTPResponseType.swift
//  RestingKit
//
//  Created by Moray on 2/16/19.
//

import Foundation

/// Represents a response from an HTTP request.
public protocol HTTPResponseType {
    /// The type of the body.
    associatedtype BodyType

    /// The body of the response.
    var body: BodyType { get }
    /// The headers of the response.
    var headers: [String: String] { get }
}
