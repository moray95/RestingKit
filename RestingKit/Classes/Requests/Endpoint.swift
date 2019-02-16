//
//  Endpoint.swift
//  RestingKit
//
//  Created by Moray on 2/16/19.
//

import Alamofire
import Foundation

public enum RequestEncoding {
    case json
    case query
}

public struct Endpoint<RequestType: Encodable, ResponseType: Decodable> {
    public let path: String
    public let method: HTTPMethod
    public let encoding: RequestEncoding

    public init(path: String, method: HTTPMethod, encoding: RequestEncoding) {
        self.path = path
        self.method = method
        self.encoding = encoding
    }
}
