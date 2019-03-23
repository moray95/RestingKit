//
//  HTTPResponse.swift
//  RestingKit
//
//  Created by Moray on 2/16/19.
//

import Foundation

/// Represents a higher-level HTTP Response.
public class HTTPResponse<T>: HTTPResponseType {
    public typealias BodyType = T

    /// The decoded body of the response.
    public let body: T
    /// The headers of the response.
    public let headers: [String: String]

    ///
    /// Creates a new `HTTPResponse`.
    ///
    /// - parameter body: The decoded body of the response.
    /// - parameter headers: The headers of the response.
    ///
    public init(body: T, headers: [String: String]) {
        self.body = body
        self.headers = headers
    }
}

extension HTTPResponse {
    static func from<T: Decodable>(response: HTTPDataResponse, decoder: JSONDecoder) throws -> HTTPResponse<T> {
        let data = response.data
        let object = try decoder.decode(T.self, from: data)
        //swiftlint:disable:next force_cast
        let headers = response.urlResponse.allHeaderFields as! [String: String]
        return HTTPResponse<T>(body: object, headers: headers)
    }

    static func empty(response: HTTPDataResponse) -> HTTPResponse<Void> {
        //swiftlint:disable:next force_cast
        let headers = response.urlResponse.allHeaderFields as! [String: String]
        return HTTPResponse<Void>(body: (), headers: headers)
    }

    static func nullable<T: Decodable>(response: HTTPDataResponse,
                                       decoder: JSONDecoder) throws -> HTTPResponse<T?> {
        //swiftlint:disable:next force_cast
        let headers = response.urlResponse.allHeaderFields as! [String: String]
        let data = response.data
        guard !data.isEmpty else {
            return HTTPResponse<T?>(body: nil, headers: headers)
        }
        let object = try decoder.decode(T.self, from: data)
        return HTTPResponse<T?>(body: object, headers: headers)
    }
}
