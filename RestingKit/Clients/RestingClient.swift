//
//  RestingClient.swift
//  RestingKit
//
//  Created by Moray on 2/16/19.
//

import Foundation
import PromiseKit

///
/// `RestingClient` is the core class of `RestingKit`. It allows sending requests
/// and receiving their responses as promises through a high-level API.
///
/// The `RestingClient` is configured with the following components:
///
///  - `baseUrl`: The base URL of the server we want to connect. One client can only connect to a single base URL.
///     Therefore, if you wish to use multiple APIs, you should use different clients for each of them.
///  - `decoder`: The decoder to use for decoding responses.
///  - `requestConverter`: The converter to use for converting `RestingRequest`s to `HTTPRequest`s.
///  - `interceptors`: The interceptors to run for each request and response.
///  - `httpClient`: The client responsible for sending the request and receiving its response.
///
/// There are two function families within the class: `perform(_:)` and `upload(_:)`, each with several
/// overloads for convenience. Even though they do the same thing in the core, The way to achieve their goal is
/// different. `perform(_:)` sends the request by loading the request body into memory, while `upload(_:)` streams
/// the body from a file without loading it. `upload(_:)` also allows tracking upload progress. For most requests
/// `perform(_:)` should be good enough, but for cases when the request body is expected to be large, `upload(_:)`
/// should be preferred.
///
/// The process within a `RestingClient` is the following:
///
/// 1. The request converter converts the `RestingRequest` into an `HTTPRequest`.
/// 2. The interceptors are run with the produced `HTTPRequest` in the order provided.
///    At this point, one of the interceptors might decide to modify the request or stop the execution
///    chain by returning a response or and error.
/// 3. If the interceptors doesn't block the chain, the `HTTPClient` is called to perform the actual request.
/// 4. The response from `HTTPClient` is passed to the interceptors. At this point, an interceptor might decide
///    to change the response or recover from an error.
/// 5. The response is then converted into an `HTTPResponse` by decoding the response body.
///
/// Cases when request promises might fail:
///
/// 1. The encoding of the request has failed.
/// 2. The decoding of the response has faied.
/// 3. Networking errors.
/// 4. The response status was not 2xx.
/// 5. An interceptor decided to raise an error.
///
open class RestingClient {
    let baseUrl: String
    let decoder: JSONDecoder
    let requestConverter: RequestConverter
    let interceptors: [RestingInterceptor]
    let httpClient: HTTPClient

    ///
    /// Creates a `RestingClient` with the provided configuration.
    ///
    /// - parameter baseUrl: The base URL of the endpoint to use by the client (ex: `https://api.example.com/v2`).
    ///                      Each request's path sent through the `RestingClient` will be relative to this URL.
    /// - parameter decoder: The `JSONDecoder` to use when decoding responses from the requests.
    /// - parameter httpClient: The `HTTPClient` to use for sending the requests.
    /// - parameter requestConverter: The `RequestConverter` to use for converting `RestingRequest`s to `HTTPRequest`s.
    /// - parameter interceptors: `RestingInterceptor`s to run when sending each request and response.
    ///
    public init(baseUrl: String,
                decoder: JSONDecoder = JSONDecoder(),
                httpClient: HTTPClient = AlamofireClient(),
                requestConverter: RequestConverter,
                interceptors: [RestingInterceptor] = []) {
        self.baseUrl = baseUrl
        self.decoder = decoder
        self.httpClient = httpClient
        self.requestConverter = requestConverter
        self.interceptors = interceptors
    }

    ///
    /// Performs a request.
    ///
    /// Uses the `RequestConverter` to convert the request into an
    /// `HTTPRequest`, run the provided interceptors, call the `HTTPClient`
    /// to perform the request and finally decode the response using the
    /// provided decoder.
    ///
    /// - parameter request: The request to perform.
    ///
    /// - returns: A promise for the response.
    ///
    open func perform<RequestType: Encodable, ResponseType: Decodable>
        (_ request: RestingRequest<RequestType, ResponseType>) -> Promise<HTTPResponse<ResponseType>> {
        return performRequest(request, upload: false).promise.map { response in
            try HTTPResponse<ResponseType>.from(response: response, decoder: self.decoder)
        }
    }

    ///
    /// Performs a request. Overload for optional response type.
    ///
    /// Uses the `RequestConverter` to convert the request into an
    /// `HTTPRequest`, run the provided interceptors, call the `HTTPClient`
    /// to perform the request and finally decode the response using the
    /// provided decoder.
    ///
    /// Use this overload when the resposne might be empty. The returned
    /// promise will resolve with `nil` **if and only if** the HTTP response
    /// body is empty.
    ///
    /// - warning: A response with a content-length greater then zero will
    ///            try to decode the response to `ResponseType`.
    ///
    /// - parameter request: The request to perform.
    ///
    /// - returns: A promise for the response.
    ///
    open func perform<RequestType: Encodable, ResponseType: Decodable>
        (_ request: RestingRequest<RequestType, ResponseType?>) -> Promise<HTTPResponse<ResponseType?>> {
        return performRequest(request, upload: false).map { response in
            try HTTPResponse<ResponseType>.nullable(response: response, decoder: self.decoder)
        }.promise
    }

    ///
    /// Performs a request. Overload for empty response.
    ///
    /// Uses the `RequestConverter` to convert the request into an
    /// `HTTPRequest`, run the provided interceptors, call the `HTTPClient`
    /// to perform the request and finally decode the response using the
    /// provided decoder.
    ///
    /// Use this overload when the resposne is always empty or will always
    /// be discarded.
    ///
    /// - parameter request: The request to perform.
    ///
    /// - returns: A promise for the response.
    ///
    open func perform<RequestType: Encodable>(_ request: RestingRequest<RequestType, Nothing>)
        -> Promise<HTTPResponse<Void>> {
            return performRequest(request, upload: false).map(HTTPResponse<Void>.empty).promise
    }

    ///
    /// Uploads a request.
    ///
    /// Uses the `RequestConverter` to convert the request into an
    /// `HTTPRequest`, run the provided interceptors, call the `HTTPClient`
    /// to perform the request and finally decode the response using the
    /// provided decoder.
    ///
    /// Prefer using `upload` over `perform` when the request body way me large as is
    /// will not be loaded into memory or you want to track the upload progress
    /// of the request.
    ///
    /// - parameter request: The request to perform.
    ///
    /// - returns: A promise with progress handler for the response.
    ///
    /// - warning: The progress callback on the returned `ProgressablePromise` is
    ///            not guarenteed to be called. This behavious depends on the implementation
    ///            of the `RequestConverter` (as it needs to be converted to a streamed request)
    ///            and the `HTTPClient` (as it is its responsibility to call the handler).
    ///            Implementations provided by `RestingKit` supports the call to the
    ///            progress callback.
    ///
    open func upload<RequestType: Encodable, ResponseType: Decodable>
        (_ request: RestingRequest<RequestType, ResponseType>) -> ProgressablePromise<HTTPResponse<ResponseType>> {
        return performRequest(request, upload: true).map { response in
            try HTTPResponse<ResponseType>.from(response: response, decoder: self.decoder)
        }
    }

    ///
    /// Uploads a request. Overload for optional response type.
    ///
    /// Uses the `RequestConverter` to convert the request into an
    /// `HTTPRequest`, run the provided interceptors, call the `HTTPClient`
    /// to perform the request and finally decode the response using the
    /// provided decoder.
    ///
    /// Prefer using `upload` over `perform` when the request body way me large as is
    /// will not be loaded into memory or you want to track the upload progress
    /// of the request.
    ///
    /// Use this overload when the resposne might be empty. The returned
    /// promise will resolve with `nil` **if and only if** the HTTP response
    /// body is empty.
    ///
    /// - parameter request: The request to perform.
    ///
    /// - returns: A promise with progress handler for the response.
    ///
    /// - warning: A response with a content-length greater then zero will
    ///            try to decode the response to `ResponseType`.
    ///
    /// - warning: The progress callback on the returned `ProgressablePromise` is
    ///            not guarenteed to be called. This behavious depends on the implementation
    ///            of the `RequestConverter` (as it needs to be converted to a streamed request)
    ///            and the `HTTPClient` (as it is its responsibility to call the handler).
    ///            Implementations provided by `RestingKit` supports the call to the
    ///            progress callback.
    ///
    open func upload<RequestType: Encodable, ResponseType: Decodable>
        (_ request: RestingRequest<RequestType, ResponseType?>) -> ProgressablePromise<HTTPResponse<ResponseType?>> {
        return performRequest(request, upload: true).map { response in
            try HTTPResponse<ResponseType>.nullable(response: response, decoder: self.decoder)
        }
    }

    ///
    /// Uploads a request. Overload for empty response.
    ///
    /// Uses the `RequestConverter` to convert the request into an
    /// `HTTPRequest`, run the provided interceptors, call the `HTTPClient`
    /// to perform the request and finally decode the response using the
    /// provided decoder.
    ///
    /// Prefer using `upload` over `perform` when the request body way me large as is
    /// will not be loaded into memory or you want to track the upload progress
    /// of the request.
    ///
    /// Use this overload when the resposne is always empty or will always
    /// be discarded.
    ///
    /// - parameter request: The request to perform.
    ///
    /// - returns: A promise with progress handler for the response.
    ///
    /// - warning: The progress callback on the returned `ProgressablePromise` is
    ///            not guarenteed to be called. This behavious depends on the implementation
    ///            of the `RequestConverter` (as it needs to be converted to a streamed request)
    ///            and the `HTTPClient` (as it is its responsibility to call the handler).
    ///            Implementations provided by `RestingKit` supports the call to the
    ///            progress callback.
    ///
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
                self.runInterceptors($0, interceptors: interceptors, resolver: resolver)
            }
    }

    private func deleteFile(request: HTTPRequest) {
        if let fileUrl = request.fileUrl {
            try? FileManager.default.removeItem(at: fileUrl)
        }
    }
}
