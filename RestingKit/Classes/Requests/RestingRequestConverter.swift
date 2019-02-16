//
//  RestingRequestConverter.swift
//  RestingKit
//
//  Created by Moray on 2/16/19.
//

import Alamofire
import Foundation
import Mustache

public class RestingRequestConverter: RequestConverter {
    private class ConvertiableRasyonelRequest<RequestType: Encodable, ResponseType: Decodable>: URLRequestConvertible {
        let request: RestingRequest<RequestType, ResponseType>
        let baseUrl: String
        let jsonEncoder: JSONEncoder
        let jsonDecoder: JSONDecoder

        init(request: RestingRequest<RequestType, ResponseType>,
             baseUrl: String,
             jsonEncoder: JSONEncoder,
             jsonDecoder: JSONDecoder) {
            self.request = request
            self.baseUrl = baseUrl
            self.jsonEncoder = jsonEncoder
            self.jsonDecoder = jsonDecoder
        }

        func asURLRequest() throws -> URLRequest {
            let template = try Template(string: request.endpoint.path)
            let path = try template.render(request.pathVariables)
            var urlRequest = try URLRequest(url: "\(baseUrl)\(path)",
                                            method: request.endpoint.method,
                                            headers: request.headers)

            switch request.endpoint.encoding {
            case .json:
                urlRequest.allHTTPHeaderFields!["content-type"] = "application/json"
                urlRequest.httpBody = try jsonEncoder.encode(request.body)
            case .query:
                let jsonData = try jsonEncoder.encode(request.body)
                let dictionary = try jsonDecoder.decode([String: Any].self, from: jsonData)
                urlRequest = try URLEncoding.queryString.encode(urlRequest, with: dictionary)
            }

            return urlRequest
        }
    }

    let jsonEncoder: JSONEncoder
    let jsonDecoder: JSONDecoder

    public init(jsonEncoder: JSONEncoder, jsonDecoder: JSONDecoder) {
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }

    public func toUrlRequest<RequestType: Encodable, ResponseType: Decodable>(
        _ request: RestingRequest <RequestType, ResponseType>,
        baseUrl: String) -> URLRequestConvertible {
        return ConvertiableRasyonelRequest(request: request,
                                           baseUrl: baseUrl,
                                           jsonEncoder: jsonEncoder,
                                           jsonDecoder: jsonDecoder)
    }
}
