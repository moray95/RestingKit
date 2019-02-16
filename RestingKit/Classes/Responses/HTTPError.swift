//
//  HTTPError.swift
//  RestingKit
//
//  Created by Moray on 2/16/19.
//

import Foundation

public class HTTPError: Error {
    public let status: Int
    public let data: Data
    public let headers: [String: String]

    public init(status: Int, headers: [String: String], data: Data) {
        self.status = status
        self.headers = headers
        self.data = data
    }
}
