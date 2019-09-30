//
//  AlamofireClient.swift
//  RestingKit
//
//  Created by Moray on 2/16/19.
//

import Alamofire
import Foundation
import PromiseKit

/// An `HTTPClient` that uses `Alamofire` for sending requests.
public class AlamofireClient: HTTPClient {
    /// Errors thrown by `AlamofireClient`
    public enum Error: Swift.Error {
        /// Thrown when `Alamofire` returns no response and no error.
        case unknown
    }

    private let sessionManager: SessionManager

    /// Creates a new `AlamofireClient`.
    ///
    /// - parameter sessionManager: The session manager to use for sending requests.
    ///
    public init(sessionManager: SessionManager = SessionManager.default) {
        self.sessionManager = sessionManager
    }

    public func perform(request: HTTPRequest) -> Promise<HTTPDataResponse> {
        guard let url = request.fileUrl else {
            return perform(urlRequest: request.urlRequest)
        }
        return Promise { resolver in
            sessionManager.upload(url, with: request.urlRequest).responseData {
                self.handle(dataResponse: $0, resolver: resolver)
            }
        }
    }

    private func perform(urlRequest: URLRequest) -> Promise<HTTPDataResponse> {
        return Promise { resolver in
            sessionManager.request(urlRequest).responseData {
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

    private func upload(request: URLRequest,
                        fileUrl: URL) -> ProgressablePromise<HTTPDataResponse> {
        return ProgressablePromise<HTTPDataResponse> { resolver, progressHandler in
            sessionManager.upload(fileUrl, with: request).uploadProgress(closure: progressHandler).responseData {
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
