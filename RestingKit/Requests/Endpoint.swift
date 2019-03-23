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
    public let path: String
    public let method: HTTPMethod
    public let encoding: RequestEncoding

    ///
    /// Creates a new `Endpoint`.
    ///
    /// - parameter path: The path of the endpoint.
    /// - parameter method: The method to use for the endpoint.
    /// - parameter encoding: The parameter to use for the endpoint.
    ///
    public init(path: String, method: HTTPMethod, encoding: RequestEncoding) {
        self.path = path
        self.method = method
        self.encoding = encoding
    }
}
