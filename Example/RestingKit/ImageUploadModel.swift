//
//  ImageUploadModel.swift
//  RestingKit_Example
//
//  Created by Moray on 2/23/19.
//  Copyright © 2019 RestingKit. All rights reserved.
//

import Foundation
import RestingKit
import Alamofire

class ImageUploadModel: Encodable {
    let file: MultipartFile
    init(imageURL: URL) {
        self.file = MultipartFile(url: imageURL)
    }
}
