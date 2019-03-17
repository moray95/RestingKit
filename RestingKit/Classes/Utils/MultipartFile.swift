//
//  MultipartFile.swift
//  RestingKit
//
//  Created by Moray on 2/24/19.
//

import Foundation

public class MultipartFile: Encodable {
    public let url: URL

    public init(url: URL) {
        self.url = url
    }
}
