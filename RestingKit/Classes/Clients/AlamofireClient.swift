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
            Alamofire.request(urlRequest).responseData { dataResponse in
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
    }
}
