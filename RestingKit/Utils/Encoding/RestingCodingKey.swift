//
//  RestingCodingKey.swift
//  RestingKit
//
//  Created by Moray on 3/24/19.
//

import Foundation

class RestingCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init(stringValue: String, intValue: Int?) {
        self.stringValue = stringValue
        self.intValue = intValue
    }

    required init(stringValue: String) {
        self.stringValue = stringValue
    }

    required init(intValue: Int) {
        self.intValue = intValue
        self.stringValue = "\(intValue)"
    }
}
