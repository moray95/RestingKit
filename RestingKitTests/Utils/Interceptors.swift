//
//  Interceptors.swift
//  RestingKitTests
//
//  Created by Moray Baruh on 21.11.2019.
//  Copyright © 2019 Moray Baruh. All rights reserved.
//

import RestingKit

class MockInterceptor: RestingInterceptor {
    private(set) var calledOnRequest = false
    private(set) var calledOnResponse = false

    func intercept(request: HTTPRequest, execution: @escaping (HTTPRequest) -> ProgressablePromise<HTTPDataResponse>) -> ProgressablePromise<HTTPDataResponse> {
        calledOnRequest = true
        let promise = execution(request)
        promise.promise.ensure {
            self.calledOnResponse = true
        }.cauterize()
        return promise
    }
}
