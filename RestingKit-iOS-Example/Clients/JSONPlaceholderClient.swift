//
//  JSONPlaceholderClient.swift
//  RestingKit
//
//  Created by Moray on 2/17/19.
//  Copyright © 2019 RestingKit. All rights reserved.
//

import UIKit
import RestingKit

enum JSONPlaceholderClient {
    static let configuration = RestingRequestConverter.Configuration(contextPath: "/posts",
                                                                     headerProvider: RestingHeaderProvider(providers: [
                                                                        "X-DEVICE-ID": { UIDevice.current.identifierForVendor?.uuidString }
                                                                     ]))

    static let shared: RestingClient = RestingClient(baseUrl: "https://jsonplaceholder.typicode.com",
                                                     requestConverter: RestingRequestConverter(configuration: configuration),
                                                     interceptors: [RequestResponseLoggingInterceptor()])
}
