//
//  Endpoints.swift
//  RestingKit
//
//  Created by Moray on 2/17/19.
//  Copyright © 2019 RestingKit. All rights reserved.
//

import Foundation
import RestingKit

enum Endpoints {
    enum Posts {
        static let list = Endpoint<Nothing, [PostModel]>(.get, "/posts", encoding: .query)
        static let get = Endpoint<Nothing, PostModel>(.get, "/posts/{{post_id}}", encoding: .query)
        static let create  = Endpoint<PostCreateModel, PostModel>(.post, "/posts", encoding: .json)
    }
    enum Images {
        static let upload = Endpoint<ImageUploadModel, Nothing>(.post, "/", encoding: .multipartFormData)
    }
}
