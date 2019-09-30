//
//  RestingRequestConverter.swift
//  RestingKit
//
//  Created by Moray on 2/16/19.
//

import Alamofire
import Foundation
import Mustache

///
/// A `RequestConverter` that supports:
///
/// - Path templating using [GRMustache.swift](https://github.com/groue/GRMustache.swift)
/// - Streamed requests
///
public class RestingRequestConverter: RequestConverter {
    enum Error: Swift.Error {
        case invalidPath
    }

    let jsonEncoder: JSONEncoder
    let queryParameterEncoder: QueryParameterEncoder
    let multipartFormDataEncoder: MultipartFormDataEncoder

    ///
    /// Creates a new `RestingRequestConverter`.
    ///
    /// - parameter jsonEncoder: The encoder to use for encoding JSON request bodies.
    /// - parameter queryParameterEncoder: The encoder to use for encoding query parameters.
    /// - parameter multipartFormDataEncoder: The encoder to use for encoding mulitpart form data bodies.
    ///
    public init(jsonEncoder: JSONEncoder = JSONEncoder(),
                queryParameterEncoder: QueryParameterEncoder = QueryParameterEncoder(),
                multipartFormDataEncoder: MultipartFormDataEncoder = MultipartFormDataEncoder()) {
        self.jsonEncoder = jsonEncoder
        self.queryParameterEncoder = queryParameterEncoder
        self.multipartFormDataEncoder = multipartFormDataEncoder
    }

    /// Converts a `RestingRequest` to an `HTTPRequest`.
    public func toHTTPRequest<RequestType, ResponseType>
        (_ request: RestingRequest<RequestType, ResponseType>,
         baseUrl: String,
         forUpload: Bool
    ) throws -> HTTPRequest where RequestType: Encodable, ResponseType: Decodable {
        guard forUpload else {
            return HTTPRequest(urlRequest: try toURLRequest(request: request, baseUrl: baseUrl, withBody: true))
        }

        var urlRequest = try toURLRequest(request: request, baseUrl: baseUrl, withBody: false)

        switch request.endpoint.encoding {
        case .json:
            return HTTPRequest(urlRequest: urlRequest)
        case .multipartFormData:
            let formData = try multipartFormDataEncoder.encode(request.body)
            urlRequest.allHTTPHeaderFields!["content-type"] = formData.contentType
            return try HTTPRequest(urlRequest: urlRequest, formData: formData)
        case .query:
            return HTTPRequest(urlRequest: urlRequest)
        }
    }

    private func toURLRequest<RequestType: Encodable, ResponseType: Decodable>(
        request: RestingRequest<RequestType, ResponseType>,
        baseUrl: String,
        withBody: Bool
    ) throws -> URLRequest {
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
