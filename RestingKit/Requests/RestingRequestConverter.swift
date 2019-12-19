//
//  RestingRequestConverter.swift
//  RestingKit
//
//  Created by Moray on 2/16/19.
//

import Alamofire
import Foundation
import Mustache

///x
/// A `RequestConverter` that supports:
///
/// - Path templating using [GRMustache.swift](https://github.com/groue/GRMustache.swift)
/// - Streamed requests
///
public class RestingRequestConverter: RequestConverter {
    /// Errors thrown  by `RestingRequestConverter`.
    public enum Error: Swift.Error {
        /// The request's path is invalid.
        case invalidPath
    }

    /// The configuration settings for `RestingRequestConverter`.
    public struct Configuration {
        let jsonEncoder: JSONEncoder
        let queryParameterEncoder: QueryParameterEncoder
        let multipartFormDataEncoder: MultipartFormDataEncoder
        let contextPath: String
        let headerProvider: HeaderProvider?
        let pathVariableProvider: PathVariableProvider?

        ///
        /// Creates a new `Configuration`.
        ///
        /// - parameter jsonEncoder: The encoder to use when encoding JSON request bodies.
        /// - parameter queryParameterEncoder: The encoder to use when encoding query parameters.
        /// - parameter multipartFormDataEncoder: The encoder to use when encoding multipart/form-data bodies.
        /// - parameter contextPath: A prefix to prepend to each request's path.
        /// - parameter headerProvider: The provider to use for adding headers.
        /// - parameter pathVariableProvider: The provider to use for adding path variables.
        ///
        ///  When using header and path variable providers, the values added to individual requests overrides
        ///  the one provided by providers.
        ///
        public init(
            jsonEncoder: JSONEncoder = JSONEncoder(),
            queryParameterEncoder: QueryParameterEncoder = QueryParameterEncoder(),
            multipartFormDataEncoder: MultipartFormDataEncoder = MultipartFormDataEncoder(),
            contextPath: String = "",
            headerProvider: HeaderProvider? = nil,
            pathVariableProvider: PathVariableProvider? = nil
        ) {
            self.jsonEncoder = jsonEncoder
            self.queryParameterEncoder = queryParameterEncoder
            self.multipartFormDataEncoder = multipartFormDataEncoder
            self.contextPath = contextPath
            self.headerProvider = headerProvider
            self.pathVariableProvider = pathVariableProvider
        }
    }

    /// The configuration for the instance.
    public let configuration: Configuration

    ///
    /// Creates a new `RestingRequestConverter`.
    ///
    /// - parameter configuration: The configuration to use for the converter
    ///
    public init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
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
            let formData = try configuration.multipartFormDataEncoder.encode(request.body)
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
        let template = try Template(string: configuration.contextPath + request.endpoint.path)

        // Upon conflict, keep the variable from the request.
        let pathVariables = request
            .pathVariables
            .merging(configuration.pathVariableProvider?.variables ?? [:]) { old, _ in old }
        let path = try template.render(pathVariables)

        guard let baseUrl = URL(string: baseUrl),
            let fullUrl = URL(string: path, relativeTo: baseUrl),
            var components = URLComponents(url: fullUrl, resolvingAgainstBaseURL: true) else {
            throw Error.invalidPath
        }

        if request.endpoint.encoding == .query {
            let queryItems = try configuration.queryParameterEncoder.encode(request.body)
            // Prevent URL ending with question mark when no parameter is given
            if !queryItems.isEmpty {
                components.queryItems = queryItems
            }
        }

        // Upon conflict, keep the header from the request.
        let headers = request.headers.merging(configuration.headerProvider?.headers ?? [:]) { old, _ in old }
        var urlRequest = try URLRequest(url: try components.asURL(),
                                        method: request.endpoint.method,
                                        headers: headers)

        guard withBody else {
            return urlRequest
        }

        switch request.endpoint.encoding {
        case .json:
            urlRequest.allHTTPHeaderFields!["content-type"] = "application/json"
            urlRequest.httpBody = try configuration.jsonEncoder.encode(request.body)
        case .multipartFormData:
            let formData = try configuration.multipartFormDataEncoder.encode(request.body)
            urlRequest.allHTTPHeaderFields!["content-type"] = formData.contentType
            urlRequest.httpBody = try formData.encode()
        case .query:
            break
        }

        return urlRequest
    }
}
