//
//  RestingRequest.swift
//  RestingKit
//
//  Created by Moray on 2/16/19.
//

import Foundation

open class RestingRequest<RequestType, ResponseType> {
    public let endpoint: Endpoint<RequestType, ResponseType>
    public let body: RequestType
    public let headers: [String: String]
    public let pathVariables: [String: Any]

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
