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
    static let shared: RestingClient = {
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        let requestConverter = RestingRequestConverter(jsonEncoder: encoder, jsonDecoder: decoder)

        return RestingClient(baseUrl: "https://jsonplaceholder.typicode.com",
                             decoder: decoder,
                             httpClient: AlamofireClient(),
                             requestConverter: requestConverter,
                             interceptors: [RequestResponseLoggingInterceptor()])
    }()
}
