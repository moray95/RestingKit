//
//  RestingClient.swift
//  RestingKit
//
//  Created by Moray on 2/16/19.
//

import Foundation
import PromiseKit

open class RestingClient {
    let baseUrl: String
    let decoder: JSONDecoder
    let requestConverter: RequestConverter
    let interceptors: [RestingInterceptor]
    let httpClient: HTTPClient

    public init(baseUrl: String,
                decoder: JSONDecoder,
                httpClient: HTTPClient = AlamofireClient(),
                requestConverter: RequestConverter,
                interceptors: [RestingInterceptor] = []) {
        self.baseUrl = baseUrl
        self.decoder = decoder
        self.httpClient = httpClient
        self.requestConverter = requestConverter
        self.interceptors = interceptors
    }

    open func perform<RequestType: Encodable, ResponseType: Decodable>
        (_ request: RestingRequest<RequestType, ResponseType>) -> Promise<HTTPResponse<ResponseType>> {
        return performRequest(request).map { response in
            let data = response.data
            let object = try self.decoder.decode(ResponseType.self, from: data)
            //swiftlint:disable:next force_cast
            let headers = response.urlResponse.allHeaderFields as! [String: String]
            return HTTPResponse(body: object, headers: headers)
        }
    }

    open func perform<RequestType: Encodable, ResponseType: Decodable>
        (_ request: RestingRequest<RequestType, ResponseType?>) -> Promise<HTTPResponse<ResponseType?>> {
        return performRequest(request).map { response in
            //swiftlint:disable:next force_cast
            let headers = response.urlResponse.allHeaderFields as! [String: String]
            let data = response.data
            guard !data.isEmpty else {
                return HTTPResponse(body: nil, headers: headers)
            }
            let object = try self.decoder.decode(ResponseType.self, from: data)
            return HTTPResponse(body: object, headers: headers)
        }
    }

    open func perform<RequestType: Encodable>(_ request: RestingRequest<RequestType, Nothing>)
        -> Promise<HTTPResponse<Void>> {
        return performRequest(request).map { response in
            //swiftlint:disable:next force_cast
            let headers = response.urlResponse.allHeaderFields as! [String: String]
            return HTTPResponse(body: (), headers: headers)
        }
    }

    private func performRequest<RequestType: Encodable, ResponseType: Decodable>
        (_ request: RestingRequest<RequestType, ResponseType>) -> Promise<HTTPDataResponse> {
        return convertRequest(request).then {
            return self.runInterceptors($0, interceptors: self.interceptors) { urlRequest in
                return self.httpClient.perform(urlRequest: urlRequest)
            }.get { dataResponse in
                    let urlResponse = dataResponse.urlResponse
                    guard (200..<300).contains(urlResponse.statusCode) else {
                        //swiftlint:disable:next force_cast
                        let headers = urlResponse.allHeaderFields as! [String: String]
                        throw HTTPError(status: urlResponse.statusCode, headers: headers, data: dataResponse.data)
                    }
            }
        }
    }

    private func convertRequest<RequestType: Encodable, ResponseType: Decodable>
        (_ request: RestingRequest<RequestType, ResponseType>) -> Promise<URLRequest> {
        return Promise {
            do {
                $0.fulfill(try requestConverter.toUrlRequest(request, baseUrl: baseUrl).asURLRequest())
            } catch {
                $0.reject(error)
            }
        }
    }

    private func runInterceptors(_ request: URLRequest, interceptors: [RestingInterceptor],
                                 resolver: @escaping (URLRequest) -> Promise<HTTPDataResponse>)
        -> Promise<HTTPDataResponse> {
        guard !interceptors.isEmpty else {
            return resolver(request)
        }
        var interceptors = interceptors
        let nextInterceptor = interceptors.removeFirst()
        return nextInterceptor.intercept(request: request) {
            runInterceptors($0, interceptors: interceptors, resolver: resolver)
        }
    }
}
