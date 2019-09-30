//
//  RestingInterceptor.swift
//  RestingKit
//
//  Created by Moray on 2/16/19.
//

import Foundation
import PromiseKit

///
/// Represents an object that is able to intercept requests and responses.
///
/// Sample implementation that does nothing:
///
/// ```swift
/// class EmptyInterceptor: RestingInterceptor {
///     func intercept(request: HTTPRequest, execution: Execution) -> ProgressablePromise<HTTPDataResponse> {
///         return execution()
///     }
/// }
/// ```
///
public protocol RestingInterceptor {
    /// Represents the interceptor execution chain.
    typealias Execution = (HTTPRequest) -> ProgressablePromise<HTTPDataResponse>

    ///
    /// Intercepts a sending request. The response to the request can be
    /// retrieved from the promise returned by `execution`.
    ///
    /// - parameter request: The request that is being sent.
    /// - parameter execution: The function that executes the request.
    ///
    /// - returns: A promise to the request's response.
    ///
    /// - warning: The implementation **must** call `execution` if the request
    ///            is to be sent. The implementation might decide to not send the request
    ///            or modify the request sent by passing another request to `execution`.
    ///
    func intercept(request: HTTPRequest, execution: @escaping Execution) -> ProgressablePromise<HTTPDataResponse>
}
