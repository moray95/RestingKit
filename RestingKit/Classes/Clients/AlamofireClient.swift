//
//  AlamofireClient.swift
//  RestingKit
//
//  Created by Moray on 2/16/19.
//

import Alamofire
import Foundation
import PromiseKit

public class AlamofireClient: HTTPClient {
    public enum Error: Swift.Error {
        case unknown
    }

    public init() { }

    public func perform(urlRequest: URLRequest) -> Promise<HTTPDataResponse> {
        return Promise { resolver in
            Alamofire.request(urlRequest).responseData {
                self.handle(dataResponse: $0, resolver: resolver)
            }
        }
    }

    public func perform(request: HTTPRequest) -> Promise<HTTPDataResponse> {
        guard let url = request.fileUrl else {
            return perform(urlRequest: request.urlRequest)
        }
        return Promise { resolver in
            Alamofire.upload(url, with: request.urlRequest).responseData {
                self.handle(dataResponse: $0, resolver: resolver)
            }
        }
    }

    public func upload(request: HTTPRequest) -> ProgressablePromise<HTTPDataResponse> {
        guard let fileUrl = request.fileUrl else {
            return perform(request: request).asProgressable()
        }
        return upload(request: request.urlRequest, fileUrl: fileUrl)
    }

    public func upload(request: URLRequest,
                       fileUrl: URL) -> ProgressablePromise<HTTPDataResponse> {
        return ProgressablePromise<HTTPDataResponse> { resolver, progressHandler in
            Alamofire.upload(fileUrl, with: request).uploadProgress(closure: progressHandler).responseData {
                self.handle(dataResponse: $0, resolver: resolver)
            }
        }
    }

    private func handle(dataResponse: DataResponse<Data>, resolver: Resolver<HTTPDataResponse>) {
        if let urlResponse = dataResponse.response {
            switch dataResponse.result {
            case .success(let data):
                resolver.fulfill(HTTPDataResponse(urlResponse: urlResponse, data: data))
            case .failure(let error):
                resolver.reject(error)
            }
        } else {
            resolver.reject(dataResponse.error ?? Error.unknown)
        }
    }
}
