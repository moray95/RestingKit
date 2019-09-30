//
//  HTTPError.swift
//  RestingKit
//
//  Created by Moray on 2/16/19.
//

import Foundation

/// An error thrown when a response status code is not 2xx.
public class HTTPError: Error {
    /// The status code of the response.
    public let status: Int
    /// The raw response body of the response.
    public let data: Data
    /// The headers of the response.
    public let headers: [String: String]

    /// Creates a new HTTPError with the given status code, headers and data
    public init(status: Int, headers: [String: String], data: Data) {
        self.status = status
        self.headers = headers
        self.data = data
    }
}
