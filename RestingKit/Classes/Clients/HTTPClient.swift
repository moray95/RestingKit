//
//  HTTPClient.swift
//  RestingKit
//
//  Created by Moray on 2/16/19.
//

import Foundation
import PromiseKit

public protocol HTTPClient {
    func perform(request: HTTPRequest) -> Promise<HTTPDataResponse>
    func upload(request: HTTPRequest) -> ProgressablePromise<HTTPDataResponse>
}
