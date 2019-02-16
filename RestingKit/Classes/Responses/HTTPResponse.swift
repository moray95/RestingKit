//
//  HTTPResponse.swift
//  RestingKit
//
//  Created by Moray on 2/16/19.
//

import Foundation

public class HTTPResponse<T>: HTTPResponseType {
    public typealias BodyType = T

    public let body: T
    public let headers: [String: String]

    public init(body: T, headers: [String: String]) {
        self.body = body
        self.headers = headers
    }
}
