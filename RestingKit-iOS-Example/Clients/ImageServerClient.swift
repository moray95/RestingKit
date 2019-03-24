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
    static let shared: RestingClient = RestingClient(baseUrl: "http://localhost:9000",
                                                     decoder: JSONDecoder(),
                                                     httpClient: AlamofireClient(),
                                                     requestConverter: RestingRequestConverter(),
                                                     interceptors: [RequestResponseLoggingInterceptor()])
}
