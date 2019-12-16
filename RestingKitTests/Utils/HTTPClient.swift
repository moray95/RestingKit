//
//  HTTPClient.swift
//  RestingKitTests
//
//  Created by Moray Baruh on 21.11.2019.
//  Copyright © 2019 Moray Baruh. All rights reserved.
//

import Foundation
import RestingKit
import PromiseKit

class MockHttpClient: HTTPClient {
    let responseProvider: (HTTPRequest) -> HTTPDataResponse
    let uploadDuration: TimeInterval
    let uploadCallbackCount: Int

    init(
        uploadDuration: TimeInterval = 1,
        uploadCallbackCount: Int = 10,
        responseProvider: @escaping (HTTPRequest) -> HTTPDataResponse
    ) {
        self.uploadDuration = 1
        self.uploadCallbackCount = uploadCallbackCount
        self.responseProvider = responseProvider
    }

    func perform(request: HTTPRequest) -> Promise<HTTPDataResponse> {
        Promise.value(responseProvider(request))
    }

    func upload(request: HTTPRequest) -> ProgressablePromise<HTTPDataResponse> {
        ProgressablePromise<HTTPDataResponse> { resolver, progressHandler in
            let delta = uploadDuration / Double(uploadCallbackCount)
            var promise = Promise.value(())

            for i in 0..<uploadCallbackCount {
                promise = promise.get {
                    let progress =  Progress(totalUnitCount: Int64(self.uploadCallbackCount))
                    progress.completedUnitCount = Int64(i)
                    progressHandler(progress)
                }.asVoid().then { after(seconds: delta) }
            }
            promise
                .map { self.responseProvider(request) }
                .done(resolver.fulfill)
                .catch(resolver.reject)
        }
    }
}

protocol MockHTTPClientDelegator: HTTPClient {
    var uploadDuration: TimeInterval { get }
    var uploadCallbackCount: Int { get }

    func response(for: HTTPRequest) -> HTTPDataResponse
}

extension MockHTTPClientDelegator {
    var httpClient: MockHttpClient {
        MockHttpClient(uploadDuration: uploadDuration, uploadCallbackCount: uploadCallbackCount, responseProvider: response(for:))
    }

    func perform(request: HTTPRequest) -> Promise<HTTPDataResponse> {
        httpClient.perform(request: request)
    }

    func upload(request: HTTPRequest) -> ProgressablePromise<HTTPDataResponse> {
        httpClient.upload(request: request)
    }
}

class EchoHttpClient: MockHTTPClientDelegator {
    let status: Int
    let uploadDuration: TimeInterval
    let uploadCallbackCount: Int

    init(status: Int = 200, uploadDuration: TimeInterval = 1, uploadCallbackCount: Int = 10) {
        self.status = status
        self.uploadDuration = uploadDuration
        self.uploadCallbackCount = uploadCallbackCount
    }

    func response(for request: HTTPRequest) -> HTTPDataResponse {
        let urlResponse = HTTPURLResponse(url: request.urlRequest.url!, statusCode: status, httpVersion: nil, headerFields: request.urlRequest.allHTTPHeaderFields)!
        let data = request.urlRequest.httpBody ?? getDataFrom(url: request.fileUrl)
        return HTTPDataResponse(urlResponse: urlResponse, data: data)
    }

    private func getDataFrom(url: URL?) -> Data {
        guard let url = url else { return Data() }
        return try! Data(contentsOf: url)
    }
}

class NoContentHttpClient: MockHTTPClientDelegator {
    let uploadDuration: TimeInterval
    let uploadCallbackCount: Int

    init(uploadDuration: TimeInterval = 1, uploadCallbackCount: Int = 10) {
        self.uploadDuration = uploadDuration
        self.uploadCallbackCount = uploadCallbackCount
    }

    func response(for request: HTTPRequest) -> HTTPDataResponse {
        let urlResponse = HTTPURLResponse(url: request.urlRequest.url!, statusCode: 204, httpVersion: nil, headerFields: request.urlRequest.allHTTPHeaderFields)!
        return HTTPDataResponse(urlResponse: urlResponse, data: Data())
    }
}
