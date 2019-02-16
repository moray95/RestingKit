//
//  PostModel.swift
//  RestingKit
//
//  Created by Moray on 2/17/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

struct PostModel: Codable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}
