//
//  HTTPRequest.swift
//  RestingKit
//
//  Created by Moray on 3/4/19.
//

import Alamofire
import Foundation

/// Represents a lower-level HTTP request.
public struct HTTPRequest {
    enum Error: Swift.Error {
        case tempFileCreationFailed
    }

    /// The underlaying `URLRequest`
    public let urlRequest: URLRequest

    ///
    /// A URL to a file to be used as a streamed request body.
    /// If `fileURL` is not `nil`, `urlRequest.httpBody` and
    /// `urlRequest.httpBodyStream` **must** be `nil`.
    ///
    public let fileUrl: URL?

    /// Creates a new request from the given `URLRequest` and file URL.
    /// The request will be streamed if fileURL is not `nil`.
    public init(urlRequest: URLRequest, fileUrl: URL?) {
        self.urlRequest = urlRequest
        self.fileUrl = fileUrl
        validate()
    }

    /// Creates a new non-streamed request from the given `URLRequest`
    public init(urlRequest: URLRequest) {
        self.init(urlRequest: urlRequest, fileUrl: nil)
    }

    /// Creates a new streamed request from the given `URLRequest` and file URL
    public init(urlRequest: URLRequest, fileUrl: URL) {
        self.init(urlRequest: urlRequest, fileUrl: fileUrl as URL?)
    }

    ///
    /// Creates a new streamed request from the given `URLRequest` and `MultipartFormData`.
    /// This initializer creates a temporary file to store the given request body and calls `init(urlRequest:fileUrl:)`.
    ///
    public init(urlRequest: URLRequest, formData: MultipartFormData) throws {
        guard let tmpFile = NSURL.fileURL(withPathComponents: [NSTemporaryDirectory(), UUID().uuidString]) else {
            throw Error.tempFileCreationFailed
        }
        try formData.writeEncodedData(to: tmpFile)
        self.init(urlRequest: urlRequest, fileUrl: tmpFile)
    }

    private func validate() {
        if fileUrl != nil {
            if urlRequest.httpBody != nil {
                fatalError("urlRequest.httpBody must be nil when fileUrl is not nil")
            }
            if urlRequest.httpBodyStream != nil {
                fatalError("urlRequest.httpBodyStream must be nil when fileUrl is not nil")
            }
        }
    }
}
