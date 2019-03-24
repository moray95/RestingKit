//
//  RestingRequestConverter.swift
//  RestingKit
//
//  Created by Moray on 2/16/19.
//

import Alamofire
import Foundation

///
/// A `RequestConverter` that supports:
///
/// - Path templating using [GRMustache.swift](https://github.com/groue/GRMustache.swift)
/// - Streamed requests
///
public class RestingRequestConverter: RequestConverter {
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

    public func toHTTPRequest<RequestType, ResponseType>
        (_ request: RestingRequest<RequestType, ResponseType>,
         baseUrl: String,
         forUpload: Bool) throws -> HTTPRequest where RequestType: Encodable, ResponseType: Decodable {
        return try RestingHTTPRequestConvertible(request: request,
                                                 baseUrl: baseUrl,
                                                 jsonEncoder: jsonEncoder,
                                                 queryParameterEncoder: queryParameterEncoder,
                                                 multipartFormDataEncoder: multipartFormDataEncoder,
                                                 forUpload: forUpload).toHTTPRequest()
    }
}
