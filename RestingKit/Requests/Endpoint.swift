//
//  Endpoint.swift
//  RestingKit
//
//  Created by Moray on 2/16/19.
//

import Alamofire
import Foundation

/// Encoding strategies for request parameters.
public enum RequestEncoding {
    /// JSON encoding as in RFC 8259.
    case json
    /// Query parameter encoding as in RFC 3986 3.4.
    case query
    /// Multipart form data encoding as in RFC 2388.
    case multipartFormData
}

///
/// An endpoint in the REST meaning.
///
/// - parameter RequestType: The type of the request parameter.
/// - parameter ResponseType: The type of th response.
///
public struct Endpoint<RequestType, ResponseType> {
    /// The method to use for the endpoint.
    public let method: HTTPMethod
    /// The path of the endpoint.
    public let path: String
    /// The parameter encoding to use for the endpoint.
    public let encoding: RequestEncoding

    ///
    /// Creates a new `Endpoint`.
    ///
    /// - parameter method: The method to use for the endpoint.
    /// - parameter path: The path of the endpoint.
    /// - parameter encoding: The parameter encoding to use for the endpoint.
    ///
    public init(_ method: HTTPMethod, _ path: String, encoding: RequestEncoding) {
        self.path = path
        self.method = method
        self.encoding = encoding
    }
}
