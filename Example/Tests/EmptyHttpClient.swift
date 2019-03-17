//
//  EmptyHttpClient.swift
//  RestingKit_Example
//
//  Created by Moray on 2/18/19.
//  Copyright © 2019 RestingKit. All rights reserved.
//

import Foundation
import RestingKit
import PromiseKit

class EmptyHTTPClient: HTTPClient {
    func upload(request: HTTPRequest) -> ProgressablePromise<HTTPDataResponse> {
        return ProgressablePromise(promise: perform(request: request))
    }

    func perform(request: HTTPRequest) -> Promise<HTTPDataResponse> {
        let urlResponse = HTTPURLResponse(url: request.urlRequest.url!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        let response = HTTPDataResponse(urlResponse: urlResponse, data: Data())
        return Promise.value(response)
    }
}
