//
//  JSONPlaceholderClient.swift
//  RestingKit
//
//  Created by Moray on 2/17/19.
//  Copyright © 2019 RestingKit. All rights reserved.
//

import Foundation
import RestingKit

enum JSONPlaceholderClient {
    static let shared: RestingClient = RestingClient(baseUrl: "https://jsonplaceholder.typicode.com",
                                                     decoder: JSONDecoder(),
                                                     httpClient: AlamofireClient(),
                                                     requestConverter: RestingRequestConverter(),
                                                     interceptors: [RequestResponseLoggingInterceptor()])
}
