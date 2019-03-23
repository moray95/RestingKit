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
    let jsonDecoder: JSONDecoder
    let multipartFormDataEncoder: MultipartFormDataEncoder

    public init(jsonEncoder: JSONEncoder = JSONEncoder(),
                jsonDecoder: JSONDecoder = JSONDecoder(),
                multipartFormDataEncoder: MultipartFormDataEncoder = MultipartFormDataEncoder()) {
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
        self.multipartFormDataEncoder = multipartFormDataEncoder
    }

    public func toHTTPRequest<RequestType, ResponseType>
        (_ request: RestingRequest<RequestType, ResponseType>,
         baseUrl: String,
         forUpload: Bool) throws -> HTTPRequest where RequestType: Encodable, ResponseType: Decodable {
        return try RestingHTTPRequestConvertible(request: request,
                                                 baseUrl: baseUrl,
                                                 jsonEncoder: jsonEncoder,
                                                 jsonDecoder: jsonDecoder,
                                                 multipartFormDataEncoder: multipartFormDataEncoder,
                                                 forUpload: forUpload).toHTTPRequest()
    }
}
