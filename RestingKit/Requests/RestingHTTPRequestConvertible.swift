//
//  RestingHTTPRequestConvertible.swift
//  RestingKit
//
//  Created by Moray on 2/23/19.
//

import Alamofire
import Foundation
import Mustache

class RestingHTTPRequestConvertible<RequestType: Encodable, ResponseType: Decodable> {
    enum Error: Swift.Error {
        case invalidPath
    }

    let request: RestingRequest<RequestType, ResponseType>
    let baseUrl: String
    let jsonEncoder: JSONEncoder
    let queryParameterEncoder: QueryParameterEncoder
    let multipartFormDataEncoder: MultipartFormDataEncoder
    let forUpload: Bool

    init(request: RestingRequest<RequestType, ResponseType>,
         baseUrl: String,
         jsonEncoder: JSONEncoder,
         queryParameterEncoder: QueryParameterEncoder,
         multipartFormDataEncoder: MultipartFormDataEncoder,
         forUpload: Bool) {
        self.request = request
        self.baseUrl = baseUrl
        self.jsonEncoder = jsonEncoder
        self.queryParameterEncoder = queryParameterEncoder
        self.multipartFormDataEncoder = multipartFormDataEncoder
        self.forUpload = forUpload
    }

    func toHTTPRequest() throws -> HTTPRequest {
        if !forUpload {
            return DefaultHTTPRequest(urlRequest: try asURLRequest(withBody: true))
        }
        var urlRequest = try asURLRequest(withBody: false)

        switch request.endpoint.encoding {
        case .json:
            return DefaultHTTPRequest(urlRequest: urlRequest)
        case .multipartFormData:
            let formData = try multipartFormDataEncoder.encode(request.body)
            urlRequest.allHTTPHeaderFields!["content-type"] = formData.contentType
            return try StreamedHTTPRequest(urlRequest: urlRequest, formData: formData)
        case .query:
            return DefaultHTTPRequest(urlRequest: urlRequest)
        }
    }

    func asURLRequest(withBody: Bool) throws -> URLRequest {
        let template = try Template(string: request.endpoint.path)
        let path = try template.render(request.pathVariables)

        guard let baseUrl = URL(string: baseUrl),
            let fullUrl = URL(string: path, relativeTo: baseUrl),
            var components = URLComponents(url: fullUrl, resolvingAgainstBaseURL: true) else {
            throw Error.invalidPath
        }

        if request.endpoint.encoding == .query {
            let queryItems = try queryParameterEncoder.encode(request.body)
            // Prevent URL ending with question mark when no parameter is given
            if !queryItems.isEmpty {
                components.queryItems = queryItems
            }
        }

        var urlRequest = try URLRequest(url: try components.asURL(),
                                        method: request.endpoint.method,
                                        headers: request.headers)

        guard withBody else {
            return urlRequest
        }

        switch request.endpoint.encoding {
        case .json:
            urlRequest.allHTTPHeaderFields!["content-type"] = "application/json"
            urlRequest.httpBody = try jsonEncoder.encode(request.body)
        case .multipartFormData:
            let formData = try multipartFormDataEncoder.encode(request.body)
            urlRequest.allHTTPHeaderFields!["content-type"] = formData.contentType
            urlRequest.httpBody = try formData.encode()
        case .query:
            break
        }

        return urlRequest
    }
}
