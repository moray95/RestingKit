//
//  RestingRequest.swift
//  RestingKit
//
//  Created by Moray on 2/16/19.
//

import Foundation

///
/// Represents a high-level HTTP Request.
///
/// - parameter RequestType: The type of the request parameters.
/// - parameter ResponseType: The type of response.
///
open class RestingRequest<RequestType, ResponseType> {
    /// The endpoint for the request.
    public let endpoint: Endpoint<RequestType, ResponseType>
    /// The parameters for the request.
    public let body: RequestType
    /// The headers for the request.
    public let headers: [String: String]
    /// The variables to substitute in the endpoint's path.
    public let pathVariables: [String: Any]

    ///
    /// Creates a new `RestingRequest`.
    ///
    /// - parameter endpoint: The endpoint for the request.
    /// - parameter body: The parameters for the request.
    /// - parameter header: The headers for the request.
    /// - parameter pathVariables: The variables to substitute in the endpoint's path.
    ///
    public init(endpoint: Endpoint<RequestType, ResponseType>,
                body: RequestType,
                headers: [String: String] = [:],
                pathVariables: [String: Any] = [:]) {
            self.endpoint = endpoint
            self.body = body
            self.headers = headers
            self.pathVariables = pathVariables
    }
}
