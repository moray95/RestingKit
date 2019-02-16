//
//  HTTPDataResponse.swift
//  RestingKit
//
//  Created by Moray on 2/16/19.
//

import Foundation

public class HTTPDataResponse {
    public let urlResponse: HTTPURLResponse
    public let data: Data

    public init(urlResponse: HTTPURLResponse, data: Data) {
        self.urlResponse = urlResponse
        self.data = data
    }
}
