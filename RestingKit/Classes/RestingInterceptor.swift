//
//  RestingInterceptor.swift
//  RestingKit
//
//  Created by Moray on 2/16/19.
//

import Foundation
import PromiseKit

public protocol RestingInterceptor {
    typealias Execution = (HTTPRequest) -> ProgressablePromise<HTTPDataResponse>
    func intercept(request: HTTPRequest, execution: Execution) -> ProgressablePromise<HTTPDataResponse>
}
