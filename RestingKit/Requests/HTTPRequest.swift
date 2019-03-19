//
//  HTTPRequest.swift
//  RestingKit
//
//  Created by Moray on 3/4/19.
//

import Alamofire
import Foundation

public protocol HTTPRequest {
    var urlRequest: URLRequest { get }
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
