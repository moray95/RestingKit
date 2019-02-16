//
//  Endpoints.swift
//  RestingKit
//
//  Created by Moray on 2/17/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import RestingKit

enum Endpoints {
    enum Posts {
        static let list = Endpoint<Nothing, [PostModel]>(path: "/posts", method: .get, encoding: .query)
        static let get = Endpoint<Nothing, PostModel>(path: "/posts/{{post_id}}", method: .get, encoding: .query)
        static let create  = Endpoint<PostCreateModel, PostModel>(path: "/posts", method: .post, encoding: .json)
    }
}
