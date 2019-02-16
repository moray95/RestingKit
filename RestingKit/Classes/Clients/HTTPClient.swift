//
//  HTTPClient.swift
//  RestingKit
//
//  Created by Moray on 2/16/19.
//

import Foundation
import PromiseKit

public protocol HTTPClient {
    func perform(urlRequest: URLRequest) -> Promise<HTTPDataResponse>
}
