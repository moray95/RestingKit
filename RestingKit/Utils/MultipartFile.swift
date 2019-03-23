//
//  MultipartFile.swift
//  RestingKit
//
//  Created by Moray on 2/24/19.
//

import Foundation

///
/// Represents a file to be sent through a multipart/form-data request.
///
/// - warning:  Even tough the class is `Encodable`, it is supposed to be encoded
///             with `MultipartFormDataEncoder`. Encoding with a different encoder
///             will result in an undefined result.
///
public class MultipartFile: Encodable {
    /// The URL of the file to upload.
    public let url: URL

    ///
    /// Creates a new `MultipartFile`.
    ///
    /// - parameter url: The URL of the file to upload.
    ///
    public init(url: URL) {
        self.url = url
    }
}
