//
//  HTTPRequest.swift
//  RestingKit
//
//  Created by Moray on 3/4/19.
//

import Alamofire
import Foundation

/// Represents a lower-level HTTP request.
public protocol HTTPRequest {
    /// The underlaying `URLRequest`
    var urlRequest: URLRequest { get }
    ///
    /// A URL to a file to be used as a streamed request body.
    /// If `fileURL` is not `nil`, `urlRequest.httpBody` and
    /// `urlRequest.httpBodyStream` **must** be `nil`.
    ///
    var fileUrl: URL? { get }
}

class StreamedHTTPRequest: HTTPRequest {
    enum Error: Swift.Error {
        case tempFileCreationFailed
    }

    let urlRequest: URLRequest
    let fileUrl: URL?

    init(urlRequest: URLRequest, fileUrl: URL) {
        precondition(urlRequest.httpBody == nil)
        self.urlRequest = urlRequest
        self.fileUrl = fileUrl
    }

    convenience init(urlRequest: URLRequest, formData: MultipartFormData) throws {
        guard let tmpFile = NSURL.fileURL(withPathComponents: [NSTemporaryDirectory(), UUID().uuidString]) else {
            throw Error.tempFileCreationFailed
        }
        try formData.writeEncodedData(to: tmpFile)
        self.init(urlRequest: urlRequest, fileUrl: tmpFile)
    }
}

class DefaultHTTPRequest: HTTPRequest {
    let urlRequest: URLRequest
    let fileUrl: URL? = nil

    init(urlRequest: URLRequest) {
        self.urlRequest = urlRequest
    }
}

public class BasicHTTPRequest: HTTPRequest {
    public let urlRequest: URLRequest
    public let fileUrl: URL?

    public init(urlRequest: URLRequest, fileUrl: URL?) {
        self.urlRequest = urlRequest
        self.fileUrl = fileUrl
    }
}
