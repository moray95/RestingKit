//
//  Utils.swift
//  RestingKitTests
//
//  Created by Moray Baruh on 21.11.2019.
//  Copyright © 2019 Moray Baruh. All rights reserved.
//

import XCTest
import RestingKit
import PromiseKit

struct SimpleModel: Codable, Equatable {
    let stringValue: String
    let integer: Int
}

struct NestedModel: Encodable {
    let nested: SimpleModel
}

struct ArrayModel<T: Encodable>: Encodable {
    let array: [T]
}


struct PostModel: Codable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}

struct PostCreateModel: Codable {
    let userId: Int
    let title: String
    let body: String

    init(userId: Int, title: String, body: String) {
        self.userId = userId
        self.title = title
        self.body = body
    }
}

class ImageUploadModel: Encodable {
    let file: MultipartFile
    init(imageURL: URL) {
        self.file = MultipartFile(url: imageURL)
    }
}
