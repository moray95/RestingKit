//
//  PostCreateModel.swift
//  RestingKit
//
//  Created by Moray on 2/17/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

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
