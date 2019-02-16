//
//  RestingInterceptor.swift
//  RestingKit
//
//  Created by Moray on 2/16/19.
//

import Foundation
import PromiseKit

public protocol RestingInterceptor {
    func intercept(request: URLRequest, execution: (URLRequest) -> Promise<HTTPDataResponse>)
        -> Promise<HTTPDataResponse>
}
