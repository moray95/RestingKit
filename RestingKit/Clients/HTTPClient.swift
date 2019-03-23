//
//  HTTPClient.swift
//  RestingKit
//
//  Created by Moray on 2/16/19.
//

import Foundation
import PromiseKit

/// An `HTTPClient` is responsible sending requests.
public protocol HTTPClient {
    ///
    /// Performs an HTTP request. The returned must fail **if and only if** no
    /// response from the remote could be received. The implementation is free
    /// to chose how to handle 3xx statuses.
    ///
    /// - parameter request: The request to send.
    ///
    /// - returns: A Promise to the response.
    ///
    func perform(request: HTTPRequest) -> Promise<HTTPDataResponse>

    ///
    /// Performs an HTTP request by streaming its body present in the `fileUrl` of the request.
    /// The implementation is responsible for calling the progress handler of the promise. The returned
    /// must fail **if and only if** no response from the remote could be received. The implementation is free
    /// to chose how to handle 3xx statuses.
    ///
    /// - parameter request: The request to send.
    ///
    /// - returns: A Promise to the response.
    ///
    func upload(request: HTTPRequest) -> ProgressablePromise<HTTPDataResponse>
}
