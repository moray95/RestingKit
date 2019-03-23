//
//  RequestResponseLoggingInterceptor.swift
//  RestingKit
//
//  Created by Moray on 2/17/19.
//

import Foundation
import PromiseKit

/// An interceptor that logs requests and responses, including errors if present.
open class RequestResponseLoggingInterceptor: RestingInterceptor {
    /// Creates a new `RequestResponseLoggingInterceptor`.
    public init() { }

    open func intercept(request: HTTPRequest, execution: Execution) -> ProgressablePromise<HTTPDataResponse> {
        log(request: request)
        let promise = execution(request).get { response in
            self.log(response: response, to: request)
        }
        promise.promise.catch { error in
            self.log(error: error, to: request)
        }
        return promise
    }

    ///
    /// Logs an `HTTPRequest`.
    ///
    /// - parameter request: The request to log.
    ///
    open func log(request: HTTPRequest) {
        print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
        print("\(request.urlRequest.httpMethod!) \(request.urlRequest.url!)")
        request.urlRequest.allHTTPHeaderFields?.forEach {
            print("\($0): \($1)")
        }
        if let body = request.urlRequest.httpBody {
            if let bodyAsString = String(data: body, encoding: .utf8) {
                print(bodyAsString)
            } else {
                print("<<Response Body decoding failed>>")
            }
        }

        print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
    }

    ///
    /// Logs the response to a request.
    ///
    /// - parameter response: The response to log.
    /// - parameter request: The request sent for the response.
    ///
    open func log(response: HTTPDataResponse, to request: HTTPRequest) {
        print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
        print("\(request.urlRequest.httpMethod!) \(request.urlRequest.url!)")
        print("\(response.urlResponse.statusCode)")
        response.urlResponse.allHeaderFields.forEach {
            print("\($0): \($1)")
        }
        if let bodyAsString = String(data: response.data, encoding: .utf8) {
            print(bodyAsString)
        } else {
            print("<<Response Body decoding failed>>")
        }
        print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
    }

    ///
    /// Logs an error that occurred while sending a request.
    ///
    /// - parameter error: The error to log.
    /// - parameter request: The request that recieved the error.
    ///
    open func log(error: Error, to request: HTTPRequest) {
        print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
        print("\(request.urlRequest.httpMethod!) \(request.urlRequest.url!) failed with error:")
        print(error)
        print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
    }
}
