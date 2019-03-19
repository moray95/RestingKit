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
        return performRequest(request, upload: false).promise.map { response in
            try HTTPResponse<ResponseType>.from(response: response, decoder: self.decoder)
        }
    }

    open func perform<RequestType: Encodable, ResponseType: Decodable>
        (_ request: RestingRequest<RequestType, ResponseType?>) -> Promise<HTTPResponse<ResponseType?>> {
        return performRequest(request, upload: false).map { response in
            try HTTPResponse<ResponseType>.nullable(response: response, decoder: self.decoder)
        }.promise
    }

    open func perform<RequestType: Encodable>(_ request: RestingRequest<RequestType, Nothing>)
        -> Promise<HTTPResponse<Void>> {
            return performRequest(request, upload: false).map(HTTPResponse<Void>.empty).promise
    }

    open func upload<RequestType: Encodable, ResponseType: Decodable>
        (_ request: RestingRequest<RequestType, ResponseType>) -> ProgressablePromise<HTTPResponse<ResponseType>> {
        return performRequest(request, upload: true).map { response in
            try HTTPResponse<ResponseType>.from(response: response, decoder: self.decoder)
        }
    }

    open func upload<RequestType: Encodable, ResponseType: Decodable>
        (_ request: RestingRequest<RequestType, ResponseType?>) -> ProgressablePromise<HTTPResponse<ResponseType?>> {
        return performRequest(request, upload: true).map { response in
            try HTTPResponse<ResponseType>.nullable(response: response, decoder: self.decoder)
        }
    }

    open func upload<RequestType: Encodable>(_ request: RestingRequest<RequestType, Nothing>)
        -> ProgressablePromise<HTTPResponse<Void>> {
            return performRequest(request, upload: true).map(HTTPResponse<Void>.empty)
    }

    private func performRequest<RequestType: Encodable, ResponseType: Decodable>
        (_ request: RestingRequest<RequestType, ResponseType>, upload: Bool) -> ProgressablePromise<HTTPDataResponse> {
        return convertRequest(request, forUpload: upload).then { request in
            self.runInterceptors(request, interceptors: self.interceptors) { request in
                self.uplaodOrPerform(request: request, upload: upload).ensure {
                    self.deleteFile(request: request)
                }
            }
        }.get { dataResponse in
                let urlResponse = dataResponse.urlResponse
                guard (200..<300).contains(urlResponse.statusCode) else {
                    //swiftlint:disable:next force_cast
                    let headers = urlResponse.allHeaderFields as! [String: String]
                    throw HTTPError(status: urlResponse.statusCode, headers: headers, data: dataResponse.data)
                }
        }
    }

    private func uplaodOrPerform(request: HTTPRequest, upload: Bool) -> ProgressablePromise<HTTPDataResponse> {
        if upload {
            return httpClient.upload(request: request)
        } else {
            return httpClient.perform(request: request).asProgressable()
        }
    }

    private func convertRequest<RequestType: Encodable, ResponseType: Decodable>
        (_ request: RestingRequest<RequestType, ResponseType>, forUpload: Bool) -> ProgressablePromise<HTTPRequest> {
        return ProgressablePromise { (resolver: Resolver<HTTPRequest>, _: ProgressHandler) throws -> Void in
            let request = try requestConverter.toHTTPRequest(request,
                                                             baseUrl: baseUrl,
                                                             forUpload: forUpload)
            resolver.fulfill(request)
        }
    }

    private func runInterceptors(_ request: HTTPRequest, interceptors: [RestingInterceptor],
                                 resolver: @escaping (HTTPRequest) -> ProgressablePromise<HTTPDataResponse>)
        -> ProgressablePromise<HTTPDataResponse> {
            guard !interceptors.isEmpty else {
                return resolver(request)
            }
            var interceptors = interceptors
            let nextInterceptor = interceptors.removeFirst()
            return nextInterceptor.intercept(request: request) {
                runInterceptors($0, interceptors: interceptors, resolver: resolver)
            }
    }

    private func deleteFile(request: HTTPRequest) {
        if let fileUrl = request.fileUrl {
            try? FileManager.default.removeItem(at: fileUrl)
        }
    }
}
