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

    open func intercept(request: URLRequest, execution: (URLRequest) -> Promise<HTTPDataResponse>)
        -> Promise<HTTPDataResponse> {
        log(request: request)
        let promise = execution(request).get { response in
            self.log(response: response, to: request)
        }
        promise.catch { error in
            self.log(error: error, to: request)
        }
        return promise
    }

    open func log(request: URLRequest) {
        print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
        print("\(request.httpMethod!) \(request.url!)")
        request.allHTTPHeaderFields?.forEach {
            print("\($0): \($1)")
        }
        if let body = request.httpBody {
            if let bodyAsString = String(data: body, encoding: .utf8) {
                print(bodyAsString)
            } else {
                print("<<Response Body decoding failed>>")
            }
        }

        print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
    }

    open func log(response: HTTPDataResponse, to request: URLRequest) {
        print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
        print("\(request.httpMethod!) \(request.url!)")
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

    open func log(error: Error, to request: URLRequest) {
        print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
        print("\(request.httpMethod!) \(request.url!) failed with error:")
        print(error)
        print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
    }
}
