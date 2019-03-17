//
//  RequestResponseLoggingInterceptor.swift
//  RestingKit
//
//  Created by Moray on 2/17/19.
//

import Foundation
import PromiseKit

open class RequestResponseLoggingInterceptor: RestingInterceptor {
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

    open func log(error: Error, to request: HTTPRequest) {
        print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
        print("\(request.urlRequest.httpMethod!) \(request.urlRequest.url!) failed with error:")
        print(error)
        print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
    }
}
