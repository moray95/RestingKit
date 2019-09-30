//
//  RequestConverter.swift
//  RestingKit
//
//  Created by Moray on 2/16/19.
//

import Alamofire
import Foundation

/// A protocol that converts `RestingRequest`s to `HTTPRequest`.
public protocol RequestConverter {
    ///
    /// Converts the given `RestingRequest` to an `HTTPRequest`.
    ///
    /// - parameter request: The `RestingRequest` to converter.
    /// - parameter baseUrl: The base URL to use for the request.
    /// - parameter forUpload: Wether the conversion is for an upload request or not.
    ///
    /// Implementations **should** use the `forUpload` to determine if the generated request
    /// should be streamed or not. If `forUpload` is `true`, it is expected that the returned request
    /// is streamed. If set to `false`, implementations are allowed chose wheter the request is streamed
    /// or not.
    func toHTTPRequest<RequestType: Encodable, ResponseType: Decodable>(
        _ request: RestingRequest<RequestType, ResponseType>,
        baseUrl: String,
        forUpload: Bool) throws -> HTTPRequest
}
