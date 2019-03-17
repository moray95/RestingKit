//
//  ImageServerClient.swift
//  RestingKit_Example
//
//  Created by Moray on 2/23/19.
//  Copyright © 2019 RestingKit. All rights reserved.
//

import Foundation
import RestingKit

enum ImageServerClient {
    static let shared: RestingClient = {
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        let requestConverter = RestingRequestConverter(jsonEncoder: encoder, jsonDecoder: decoder)

        return RestingClient(baseUrl: "http://localhost:9000",
                             decoder: decoder,
                             httpClient: AlamofireClient(),
                             requestConverter: requestConverter,
                             interceptors: [RequestResponseLoggingInterceptor()])
    }()
}
