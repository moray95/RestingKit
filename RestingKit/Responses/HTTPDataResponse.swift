//
//  HTTPDataResponse.swift
//  RestingKit
//
//  Created by Moray on 2/16/19.
//

import Foundation

/// Represents a lower-level HTTP Response.
public class HTTPDataResponse {
    /// The underlaying `HTTPURLResponse`.
    public let urlResponse: HTTPURLResponse
    /// The raw body of the response.
    public let data: Data

    ///
    /// Creates a new `HTTPDataResponse`.
    ///
    /// - parameter urlResponse: The underlaying `HTTPURLResponse`.
    /// - parameter data: The raw body of the response.
    ///
    public init(urlResponse: HTTPURLResponse, data: Data) {
        self.urlResponse = urlResponse
        self.data = data
    }
}
